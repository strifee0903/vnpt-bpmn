import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:greenly_app/services/moment_service.dart';
import 'package:greenly_app/ui/moments/moments_card.dart';
import 'package:greenly_app/ui/moments/moment_manager.dart';
import 'package:greenly_app/models/moment.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

String fullImageUrl(String? relativePath) {
  // Get the correct base URL for images (without /api)
  final imageBaseUrl = MomentService.imageBaseUrl;

  print('🖼️ DEBUG - Image base URL: $imageBaseUrl');
  print('🖼️ DEBUG - Relative path: $relativePath');

  if (relativePath == null || relativePath.isEmpty) {
    final defaultUrl = '$imageBaseUrl/public/images/blank_avt.jpg';
    print('🖼️ DEBUG - Using default avatar: $defaultUrl');
    return defaultUrl;
  }

  if (relativePath.startsWith('http')) {
    print('🖼️ DEBUG - Path is absolute URL: $relativePath');
    return relativePath;
  }

  String fullUrl;
  // Handle paths that start with /public
  if (relativePath.startsWith('/public')) {
    fullUrl = '$imageBaseUrl$relativePath';
  }
  // Handle paths that don't start with /
  else if (!relativePath.startsWith('/')) {
    fullUrl = '$imageBaseUrl/$relativePath';
  } else {
    fullUrl = '$imageBaseUrl$relativePath';
  }

  print('🖼️ DEBUG - Final image URL: $fullUrl');
  return fullUrl;
}

class GreenMap extends StatefulWidget {
  const GreenMap({super.key});

  @override
  State<GreenMap> createState() => _GreenMapState();
}

class _GreenMapState extends State<GreenMap> {
  LatLng? currentLocation;
  final MomentProvider _momentManager = MomentProvider();

  final MapController _mapController = MapController();
  LatLng? selectedMarker;
  OverlayEntry? panelOverlay;
  bool _hasFetched = false;

  void _removePanel() {
    panelOverlay?.remove();
    panelOverlay = null;
    selectedMarker = null;
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    // context.read<MomentProvider>().fetchAllMoments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // if (!_hasFetched) {
    //   context.read<MomentProvider>().fetchAllMoments();
    //   _hasFetched = true;
    // }
    if (mounted) {
      Future.microtask(() => Provider.of<MomentProvider>(context, listen: false)
          .fetchAllMoments());
    }
  }

  Future<void> _getLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍📍📍 Service enabled: $serviceEnabled');

    if (permission == LocationPermission.deniedForever) return;

    try {
      final pos = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(pos.latitude, pos.longitude);
      final nameOfLocation = await getAddressFromLatLng(
          newLocation.latitude, newLocation.longitude);

      setState(() {
        currentLocation = newLocation;
      });

      print(
          '📍📍📍 Current location: ${currentLocation!.latitude}, ${currentLocation!.longitude}');
      print('📍📍📍 Address: $nameOfLocation');
    } catch (e) {
      print('❌ Error getting location: $e');
    }
  }

  String formatPlacemark(Placemark place) {
    final parts = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ];

    // Loại bỏ các phần tử null hoặc rỗng
    final nonEmpty =
        parts.where((part) => part != null && part.trim().isNotEmpty).toList();

    return nonEmpty.join(', ');
  }

  Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final parts = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ];

        // Loại bỏ các phần tử null hoặc rỗng
        final nonEmpty = parts
            .where((part) => part != null && part.trim().isNotEmpty)
            .toList();
        return nonEmpty.join(', ');
      }
    } catch (e) {
      print('❌ Lỗi khi reverse geocoding: $e');
    }
    return null;
  }

  void _showMarkerInfo(BuildContext context, Marker point) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final markerMoments = context
                .read<MomentProvider>()
                .markerMomentMap[point.point.toString()] ??
            [];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEF5E6), // Màu xanh lá nhạt
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('📍 Bài viết ở địa điểm xanh',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: markerMoments.length,
                    itemBuilder: (context, index) {
                      final moment = markerMoments[index];
                      fullImageUrl(moment.user.u_avt);
                      String? mediaUrl;

                      if (moment.media.isNotEmpty) {
                        mediaUrl = fullImageUrl(moment.media.first.media_url);
                        print('   - Media URL: $mediaUrl');
                      }
                      return MomentCard(
                        moment: moment,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF708C5B).withOpacity(0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Đóng',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClusterInfo(BuildContext context, MarkerClusterNode cluster) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // Lọc các marker có chứa moment
        final markerMoments = cluster.markers
            .expand((m) =>
                context
                    .read<MomentProvider>()
                    .markerMomentMap[m.point.toString()] ??
                [])
            .toList();

        print(
            '📊 DEBUG - Cluster contains ${markerMoments.length} moments, ${cluster.markers.first}');
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEF5E6), // Màu xanh lá nhạt
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('📍 Các bài viết trong khu vực',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: markerMoments.length,
                    itemBuilder: (context, index) {
                      final moment = markerMoments[index];

                      if (moment.media.isNotEmpty) {}

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF708C5B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MomentCard(
                          moment: moment,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF708C5B).withOpacity(0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Đóng',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent == true) {
      // Tab này đang active → fetch lại
      // _momentsFuture = fetchAllMoments();
    }
    const String mapboxAccessToken =
        'sk.eyJ1IjoidGFtbmdvLTE1OSIsImEiOiJjbWMwMjI0OWgwNW5pMmlzY2tqdDJ4bHN1In0.mBhsHjZ8iR2rGPWRYHjgjA';
    const String mapStyleId = 'streets-v11'; // hoặc satellite-v9
    const String username = 'mapbox'; // mặc định với style public

    return Scaffold(
        body: GestureDetector(
            onTap: _removePanel,
            child: Consumer<MomentProvider>(
              builder: (context, provider, _) {
                print('🔍 markers count: ${provider.markers.length}');
                for (var marker in provider.markers) {
                  print('📍 Marker at: ${marker.point}');
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(16.047079, 108.206230),
                    zoom: 6,
                    onTap: (_, __) => _removePanel(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/$username/$mapStyleId/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken',
                      additionalOptions: {
                        'access_token': mapboxAccessToken,
                      },
                      userAgentPackageName: 'com.example.app',
                    ),
                    // MarkerLayer(
                    //   markers: provider.markers,
                    // ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 45,
                        disableClusteringAtZoom: 17,
                        zoomToBoundsOnClick: false,
                        spiderfyCluster: false,
                        size: const Size(40, 40),
                        markers: provider.markers,
                        builder: (context, cluster) {
                          return Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                            child: Center(
                              child: Text(
                                '${cluster.length}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        onClusterTap: (cluster) {
                          _showClusterInfo(context, cluster);
                        },
                        onMarkerTap: (marker) {
                          _showMarkerInfo(context, marker);
                        },
                      ),
                    ),
                  ],
                );
              },
            )));
  }
}

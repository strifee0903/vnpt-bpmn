import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson_vi/geojson_vi.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:greenly_app/services/moment_service.dart';
import 'package:greenly_app/ui/moments/moments_card.dart';
import 'package:greenly_app/models/moment.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

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
  List<List<LatLng>> vietnamPolygons = [];
  final MomentService _momentService = MomentService();
  late Future<List<Moment>> _momentsFuture;
  // PersistentBottomSheetController? _bottomSheetController;

  final List<LatLng> defaultMarkers = [
    LatLng(21.0285, 105.8542), // Hà Nội
    LatLng(10.762622, 106.660172), // Sài Gòn
    LatLng(16.047079, 108.206230), // Đà Nẵng
  ];
  final MapController _mapController = MapController();
  LatLng? selectedMarker;
  OverlayEntry? panelOverlay;

  final List<Marker> _markers = [];
  final Map<String, List<Moment>> _markerMomentMap = {};

  Future<List<Moment>> fetchMoments() async {
    print('📞 DEBUG - Fetching moments...');
    try {
      final moments = await _momentService.getNewsFeedMoments();
      print('✅ DEBUG - Successfully fetched ${moments.length} moments');
      for (var moment in moments) {
        final LatLng point = LatLng(moment.latitude!, moment.longitude!);

        _markers.add(
          Marker(
            point: point,
            width: 40,
            height: 40,
            child: const Icon(Icons.image, color: Colors.blue, size: 35),
          ),
        );

        _markerMomentMap.putIfAbsent(point.toString(), () => []).add(moment);
      }
      print('📊 DEBUG - Total markers created: ${_markers.length}');
      return moments;
    } catch (e) {
      print('❌ DEBUG - Error fetching moments: $e');
      rethrow;
    }
  }

  void _removePanel() {
    panelOverlay?.remove();
    panelOverlay = null;
    selectedMarker = null;
  }

  @override
  void initState() {
    super.initState();
    _momentsFuture = fetchMoments();
    _getLocation();
    _loadPolygon();
  }

  void _loadPolygon() async {
    final polygon = await loadVietnamPolygons();
    setState(() {
      vietnamPolygons = polygon;
    });
  }

  Future<List<List<LatLng>>> loadVietnamPolygons() async {
    final String geojsonString =
        await rootBundle.loadString('assets/vietnam.json');
    final Map<String, dynamic> jsonMap = json.decode(geojsonString);

    final feature = GeoJSONFeature.fromMap(jsonMap);
    final geometry = feature.geometry;

    final List<List<LatLng>> polygons = [];

    if (geometry is GeoJSONMultiPolygon) {
      for (final polygon in geometry.coordinates) {
        final List<LatLng> polygonPoints = [];
        for (final ring in polygon) {
          for (final coord in ring) {
            polygonPoints.add(LatLng(coord[1], coord[0]));
          }
        }
        polygons.add(polygonPoints);
      }
    } else if (geometry is GeoJSONPolygon) {
      final List<LatLng> polygonPoints = [];
      for (final ring in geometry.coordinates) {
        for (final coord in ring) {
          polygonPoints.add(LatLng(coord[1], coord[0]));
        }
      }
      polygons.add(polygonPoints);
    }

    return polygons;
  }

  Future<void> _getLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍📍📍 Service enabled: $serviceEnabled');
    final pos = await Geolocator.getCurrentPosition();

    if (permission == LocationPermission.deniedForever) return;
    setState(() async {
      currentLocation = LatLng(pos.latitude, pos.longitude);
      final nameOfLocation = await getAddressFromLatLng(currentLocation!.latitude, currentLocation!.longitude);
      print(
          '📍📍📍 Current location: ${currentLocation!.latitude}, ${currentLocation!.longitude}');
      print('📍📍📍 Address: $nameOfLocation');
    });
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

  Future<String?> getAddressFromLatLng(double latitude, double longitude) async {
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
        final markerMoments = _markerMomentMap[point.point.toString()] ?? [];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('📍 Các bài viết ở địa điểm xanh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: markerMoments.length,
                  itemBuilder: (context, index) {
                    final moment = markerMoments[index];
                    final avatarUrl = fullImageUrl(moment.user.u_avt);
                    String? mediaUrl;

                    if (moment.media.isNotEmpty) {
                      mediaUrl = fullImageUrl(moment.media.first.media_url);
                      print('   - Media URL: $mediaUrl');
                    }

                    return MomentCard(
                      username: moment.user.u_name,
                      avatar: avatarUrl,
                      status: moment.content,
                      images: moment.media.isNotEmpty
                          ? moment.media
                              .map((m) => fullImageUrl(m.media_url))
                              .toList()
                              .cast<String>()
                          : null,
                      location: moment.address,
                      time: DateFormat('yyyy-MM-dd HH:mm')
                          .format(moment.createdAt),
                      type: moment.type,
                      category: moment.category.category_name,
                      latitude: moment.latitude,
                      longitude: moment.longitude,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
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
            .expand((m) => _markerMomentMap[m.point.toString()] ?? [])
            .toList();

        print(
            '📊 DEBUG - Cluster contains ${markerMoments.length} moments, ${cluster.markers.first}');
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('📍 Các bài viết trong khu vực',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: markerMoments.length,
                  itemBuilder: (context, index) {
                    final moment = markerMoments[index];
                    final avatarUrl = fullImageUrl(moment.user.u_avt);
                    String? mediaUrl;

                    if (moment.media.isNotEmpty) {
                      mediaUrl = fullImageUrl(moment.media.first.media_url);
                      print('   - Media URL: $mediaUrl');
                    }

                    return MomentCard(
                      username: moment.user.u_name,
                      avatar: avatarUrl,
                      status: moment.content,
                      images: moment.media.isNotEmpty
                          ? moment.media
                              .map((m) => fullImageUrl(m.media_url))
                              .toList()
                              .cast<String>()
                          : null,
                      location: moment.address,
                      time: DateFormat('yyyy-MM-dd HH:mm')
                          .format(moment.createdAt),
                      type: moment.type,
                      category: moment.category.category_name,
                      latitude: moment.latitude,
                      longitude: moment.longitude,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String mapboxAccessToken =
        'sk.eyJ1IjoidGFtbmdvLTE1OSIsImEiOiJjbWMwMjI0OWgwNW5pMmlzY2tqdDJ4bHN1In0.mBhsHjZ8iR2rGPWRYHjgjA';
    const String mapStyleId = 'streets-v11'; // hoặc satellite-v9
    const String username = 'mapbox'; // mặc định với style public
    return Scaffold(
      body: GestureDetector(
        onTap: _removePanel,
        child: FutureBuilder<List<Moment>>(
          future: _momentsFuture,
          builder: (context, snapshot) {
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
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData)
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 10,
                      disableClusteringAtZoom: 17,
                      zoomToBoundsOnClick: false,
                      spiderfyCluster: false,
                      size: const Size(40, 40),
                      markers: _markers,
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
        ),
      ),
    );
  }
}

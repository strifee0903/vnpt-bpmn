import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson_vi/geojson_vi.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class GreenMap extends StatefulWidget {
  const GreenMap({super.key});

  @override
  State<GreenMap> createState() => _GreenMapState();
}

class _GreenMapState extends State<GreenMap> {
  LatLng? currentLocation;
  List<List<LatLng>> vietnamPolygons = [];
  // PersistentBottomSheetController? _bottomSheetController;

  final List<LatLng> defaultMarkers = [
    LatLng(21.0285, 105.8542), // Hà Nội
    LatLng(10.762622, 106.660172), // Sài Gòn
    LatLng(16.047079, 108.206230), // Đà Nẵng
  ];
  final MapController _mapController = MapController();
  LatLng? selectedMarker;
  OverlayEntry? panelOverlay;

  final List<Marker> markers = [
    Marker(
      point: LatLng(21.0285, 105.8542), // Hà Nội
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: Colors.red, size: 35),
    ),
    Marker(
      point: LatLng(21.03, 105.85), // gần Hà Nội
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: Colors.green, size: 35),
    ),
    Marker(
      point: LatLng(10.763, 106.661), // Sài Gòn
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: Colors.blue, size: 35),
    ),
    Marker(
      point: LatLng(10.762622, 106.660172), // Sài Gòn
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: Colors.blue, size: 35),
    ),
    Marker(
      point: LatLng(10.76325, 106.66125), // Sài Gòn
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on, color: Colors.blue, size: 35),
    ),
  ];

  // void _showPanel(BuildContext context, LatLng point) {
  //   _removePanel(); // remove cũ nếu có
  //   panelOverlay = OverlayEntry(
  //     builder: (_) => Positioned(
  //       bottom: 20,
  //       left: 20,
  //       right: 20,
  //       child: Material(
  //         borderRadius: BorderRadius.circular(12),
  //         elevation: 8,
  //         child: Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Text('Marker tại: ${point.latitude}, ${point.longitude}'),
  //         ),
  //       ),
  //     ),
  //   );
  //   Overlay.of(context).insert(panelOverlay!);
  // }

  void _removePanel() {
    panelOverlay?.remove();
    panelOverlay = null;
    selectedMarker = null;
  }

  @override
  void initState() {
    super.initState();
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

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _showMarkerInfo(BuildContext context, LatLng point) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏷️ Thông tin Marker',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('📍 Latitude: ${point.latitude.toStringAsFixed(5)}'),
              Text('📍 Longitude: ${point.longitude.toStringAsFixed(5)}'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              )
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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...cluster.markers.map((marker) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(
                    'Marker tại: ${marker.point.latitude.toStringAsFixed(5)}, ${marker.point.longitude.toStringAsFixed(5)}',
                  ),
                  // onTap: () => _showMarkerInfo(context, marker.point),
                );
              }),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              )
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
        child: FlutterMap(
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
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 10,
                disableClusteringAtZoom: 17,
                zoomToBoundsOnClick: false,
                spiderfyCluster: false,
                size: const Size(40, 40),
                markers: markers,
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
                  // _showPanel(context, cluster.markers.first.point);
                  _showClusterInfo(context, cluster);
                },
                onMarkerTap: (marker) {
                  // setState(() => selectedMarker = marker.point);
                  _showMarkerInfo(context, marker.point);

                  // _showPanel(context, marker.point);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

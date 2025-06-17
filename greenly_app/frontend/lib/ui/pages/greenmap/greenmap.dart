import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson_vi/geojson_vi.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:greenly_app/ui/pages/test_screens/screen1.dart';

class GreenMap extends StatefulWidget {
  const GreenMap({super.key});

  @override
  State<GreenMap> createState() => _GreenMapState();
}

class _GreenMapState extends State<GreenMap> {
  LatLng? currentLocation;
  List<List<LatLng>> vietnamPolygons = [];

  final List<LatLng> defaultMarkers = [
    LatLng(21.0285, 105.8542), // Hà Nội
    LatLng(10.762622, 106.660172), // Sài Gòn
    LatLng(16.047079, 108.206230), // Đà Nẵng
  ];

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

  @override
  Widget build(BuildContext context) {
    const String mapboxAccessToken =
        'sk.eyJ1IjoidGFtbmdvLTE1OSIsImEiOiJjbWMwMjI0OWgwNW5pMmlzY2tqdDJ4bHN1In0.mBhsHjZ8iR2rGPWRYHjgjA';
    const String mapStyleId = 'streets-v11'; // hoặc satellite-v9
    const String username = 'mapbox'; // mặc định với style public

    return Scaffold(
      appBar: AppBar(title: const Text('Mapbox Tile Map')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(16.047079, 108.206230),
          zoom: 6,
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
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.my_location,
                      color: Colors.blue, size: 35),
                ),
              ...defaultMarkers.map((point) => Marker(
                    point: point,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Screen1(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

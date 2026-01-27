import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPersonal extends StatelessWidget {
  final List<Marker> markers;
  final LatLng center;
  final double zoom;

  const MapPersonal({
    super.key,
    required this.markers,
    this.center = const LatLng(-6.200000, 106.816666),
    this.zoom = 13,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.hris',
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }
}

class MapMarkerData {
  final double lat;
  final double lng;
  final String? label;

  MapMarkerData({
    required this.lat,
    required this.lng,
    this.label,
  });
}

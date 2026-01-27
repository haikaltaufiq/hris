import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hr/core/theme/app_colors.dart';

class Locationtrackpage extends StatefulWidget {
  const Locationtrackpage({super.key});

  @override
  State<Locationtrackpage> createState() => _LocationtrackpageState();
}

class _LocationtrackpageState extends State<Locationtrackpage> {
  // dummy lokasi (Jakarta)
  final LatLng centerLocation = const LatLng(-6.200000, 106.816666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FlutterMap(
        options: MapOptions(
          initialCenter: centerLocation,
          initialZoom: 15,
        ),
        children: [
          // ================= TILE =================
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.hr',
          ),

          // ================= MARKER =================
          MarkerLayer(
            markers: [
              Marker(
                width: 50,
                height: 50,
                point: centerLocation,
                child: const Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

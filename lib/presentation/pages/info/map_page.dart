import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:hr/core/theme.dart'; 

class MapPageKantor extends StatelessWidget {
  final LatLng target;

  const MapPageKantor({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Lokasi Anda",
          style: GoogleFonts.poppins(
            color: AppColors.putih,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // atau CupertinoIcons.back
          color: AppColors.putih,
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
          color: AppColors.putih, // warna ikon back
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: target,
          initialZoom: 20,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'id.hr.absensi',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: target,
                width: 50,
                height: 50,
                child: FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: AppColors.secondary,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

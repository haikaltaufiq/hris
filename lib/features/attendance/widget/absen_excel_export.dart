import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';

class AbsenExcelExport extends StatefulWidget {
  const AbsenExcelExport({super.key});

  @override
  State<AbsenExcelExport> createState() => _AbsenExcelExportState();
}

class _AbsenExcelExportState extends State<AbsenExcelExport> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.0051,
      ),
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: _buildDateCard(
              title: 'Start Date',
              subtitle: 'dd/mm/yyyy',
              icon: FontAwesomeIcons.calendar,
            ),
          ),
          const SizedBox(width: 8),

          // End Date
          Expanded(
            child: _buildDateCard(
              title: 'End Date',
              subtitle: 'dd/mm/yyyy',
              icon: FontAwesomeIcons.calendar,
            ),
          ),
          const SizedBox(width: 8),

          // Calculate Button
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: FaIcon(
                FontAwesomeIcons.download,
                size: 20,
                color: AppColors.putih,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onPressed, // optional, kalau mau kasih fungsi klik
  }) {
    return ElevatedButton(
      onPressed: onPressed ?? () {}, // default no-op kalau gak dikasih
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        minimumSize: Size(
          double.infinity,
          context.isMobile ? 48 : 58,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text bagian kiri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 12,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 10,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),

          // Icon bagian kanan
          FaIcon(icon, color: AppColors.putih, size: 20),
        ],
      ),
    );
  }
}

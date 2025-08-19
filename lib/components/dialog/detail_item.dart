import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const DetailItem({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.putih,
            ),
          ),
          const SizedBox(width: 8), // jarak antar label dan value
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: color ?? AppColors.putih,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  const DetailItem({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    // Responsive sizing
    final double labelFontSize = isMobile ? 14 : (isTablet ? 15 : 16);
    final double valueFontSize = isMobile ? 14 : (isTablet ? 15 : 16);
    final double labelWidth = isMobile ? 100 : (isTablet ? 140 : 160);
    final double verticalPadding = isMobile ? 10 : 12;
    final double horizontalPadding = isMobile ? 12 : (isTablet ? 16 : 20);
    final double iconSize = isMobile ? 18 : 20;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 10),
      decoration: BoxDecoration(
        color: AppColors.putih.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        border: Border.all(
          color: AppColors.putih.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon (optional)
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: AppColors.putih.withOpacity(0.7),
              ),
              SizedBox(width: isMobile ? 8 : 10),
            ],

            // Label
            SizedBox(
              width: labelWidth,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.putih.withOpacity(0.8),
                  letterSpacing: 0.3,
                ),
              ),
            ),

            // Separator
            Container(
              width: 2,
              height: 20,
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.putih.withOpacity(0.3),
                    AppColors.putih.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            // Value
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w500,
                  color: color ?? AppColors.putih,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

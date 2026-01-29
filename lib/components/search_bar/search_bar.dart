import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';

class SearchingBar extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback? onFilter1Tap;
  final VoidCallback? onTap2;
  final ValueChanged<String>? onChanged;

  const SearchingBar({
    super.key,
    required this.controller, // wajib diisi dari luar
    this.hintText = 'Search...',
    this.onFilter1Tap,
    this.onTap2,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 48;
    const double buttonWidth = 120;
    final lihatSemua = FeatureAccess.has("lihat_semua_absensi");
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(30),
              shadowColor: const Color.fromARGB(164, 0, 0, 0)
                  .withOpacity(0.24), // warna shadow ElevatedButton kira2
              child: TextField(
                controller: controller,
                cursorColor: AppColors.putih,
                style: TextStyle(color: AppColors.putih),
                onChanged: onChanged,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: AppColors.putih.withOpacity(0.5),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  filled: true,
                  fillColor: AppColors.primary,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: AppColors.putih.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.grey),
                  ),
                ),
              ),
            ),
          ),
          if (onFilter1Tap != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                onPressed: onFilter1Tap,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateZ(1.5708)
                    ..scale(-1.0, 1.0),
                  child: FaIcon(
                    FontAwesomeIcons.arrowRightArrowLeft,
                    size: 20,
                    color: AppColors.putih,
                  ),
                ),
              ),
            ),
          ],
          if (onTap2 != null && lihatSemua) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: buttonWidth,
              height: buttonSize,
              child: ElevatedButton(
                onPressed: onTap2,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_history_rounded,
                        size: 24,
                        color: AppColors.putih,
                      ),
                      const SizedBox(width: 4),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.isIndonesian ? "Pantau" : "Track",
                            style: TextStyle(
                              color: AppColors.putih,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            context.isIndonesian ? "Lokasi" : "Location",
                            style: TextStyle(
                              color: AppColors.putih,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

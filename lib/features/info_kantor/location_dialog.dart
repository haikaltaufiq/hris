// File: lib/services/location_dialog_service.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/services/location_service.dart';
// Import sesuai dengan struktur project Anda
// import 'package:your_app/utils/app_colors.dart';
// import 'package:your_app/services/location_service.dart';
// import 'package:your_app/helpers/notification_helper.dart';

// Callback typedef untuk menangani hasil lokasi (di luar class)
typedef LocationCallback = void Function(double latitude, double longitude);

class LocationDialogService {
  /// Menampilkan dialog pilihan lokasi
  ///
  /// [context] - BuildContext dari widget yang memanggil
  /// [onLocationSelected] - Callback yang dipanggil ketika lokasi berhasil dipilih
  /// [latitudeController] - Controller untuk latitude (opsional)
  /// [longitudeController] - Controller untuk longitude (opsional)
  static Future<void> showLocationDialog({
    required BuildContext context,
    LocationCallback? onLocationSelected,
    TextEditingController? latitudeController,
    TextEditingController? longitudeController,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minWidth: 320,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 60,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern Header Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AppColors.putih,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Modern Typography
                      Text(
                        context.isIndonesian
                            ? "Pilih Lokasi"
                            : 'Choose Location',
                        style: GoogleFonts.poppins(
                          color: AppColors.putih,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.isIndonesian
                            ? "Pilih salah satu metode di bawah ini"
                            : 'Choose One of this method',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.putih.withOpacity(0.75),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Link GMaps Button
                      _buildModernButton(
                        context: context,
                        title: "Link Google Maps",
                        icon: Icons.link_rounded,
                        gradient: [
                          AppColors.green,
                          AppColors.green.withOpacity(0.8),
                        ],
                        shadowColor: AppColors.green,
                        onTap: () {
                          Navigator.of(context).pop();
                          _showGmapsInputDialog(context, onLocationSelected,
                              latitudeController, longitudeController);
                        },
                      ),

                      const SizedBox(height: 16),

                      // GPS Button
                      _buildModernButton(
                        context: context,
                        title: context.isIndonesian
                            ? "Lokasi Saat Ini"
                            : "My Location",
                        icon: Icons.my_location_rounded,
                        gradient: [
                          AppColors.secondary,
                          AppColors.secondary.withOpacity(0.8),
                        ],
                        shadowColor: AppColors.secondary,
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _handleGPSLocation(context, onLocationSelected,
                              latitudeController, longitudeController);
                        },
                      ),

                      const SizedBox(height: 28),

                      // Cancel Button
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                        child: Text(
                          context.isIndonesian ? "Batal" : "Cancel",
                          style: GoogleFonts.poppins(
                            color: AppColors.putih.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method untuk membuat button modern
  static Widget _buildModernButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.putih,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppColors.putih,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.putih.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog untuk input Google Maps URL
  static void _showGmapsInputDialog(
    BuildContext context,
    LocationCallback? onLocationSelected,
    TextEditingController? latitudeController,
    TextEditingController? longitudeController,
  ) {
    final gmapsController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 450,
                minWidth: 320,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.green,
                          AppColors.green.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.link_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    context.isIndonesian
                        ? "Masukkan Link Google Maps"
                        : 'Input Google Maps Link',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.putih,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.isIndonesian
                        ? "Salin link dari Google Maps dan tempel di sini"
                        : 'Copy Google Maps Link and Paste here',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.putih.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Modern Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: gmapsController,
                      style: GoogleFonts.poppins(
                        color: AppColors.putih,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: "https://maps.google.com/...",
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.putih.withOpacity(0.6),
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.link,
                          color: AppColors.putih.withOpacity(0.6),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      maxLines: 2,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.08),
                          ),
                          child: Text(
                            context.isIndonesian ? "Batal" : 'Cancel',
                            style: GoogleFonts.poppins(
                              color: AppColors.putih.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => _processGmapsUrl(
                            context,
                            gmapsController.text.trim(),
                            onLocationSelected,
                            latitudeController,
                            longitudeController,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            context.isIndonesian
                                ? "Gunakan Lokasi"
                                : "Use Location",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Handler untuk memproses URL Google Maps
  static void _processGmapsUrl(
    BuildContext context,
    String url,
    LocationCallback? onLocationSelected,
    TextEditingController? latitudeController,
    TextEditingController? longitudeController,
  ) {
    final regExp = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = regExp.firstMatch(url);

    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);

      if (lat != null && lng != null) {
        // Update controllers jika ada
        latitudeController?.text = lat.toStringAsFixed(7);
        longitudeController?.text = lng.toStringAsFixed(7);

        // Call callback jika ada
        onLocationSelected?.call(lat, lng);

        Navigator.of(context).pop();
        NotificationHelper.showTopNotification(
          context,
          "Lokasi berhasil ditambahkan dari Google Maps",
          isSuccess: true,
        );
      } else {
        _showUrlError(context);
      }
    } else {
      _showUrlError(context);
    }
  }

  // Handler untuk GPS location
  static Future<void> _handleGPSLocation(
    BuildContext context,
    LocationCallback? onLocationSelected,
    TextEditingController? latitudeController,
    TextEditingController? longitudeController,
  ) async {
    final position = await LocationService.getCurrentPosition();

    if (position != null) {
      final lat = position.latitude;
      final lng = position.longitude;

      // Update controllers jika ada
      latitudeController?.text = lat.toStringAsFixed(7);
      longitudeController?.text = lng.toStringAsFixed(7);

      // Call callback jika ada
      onLocationSelected?.call(lat, lng);

      NotificationHelper.showTopNotification(
        context,
        "Lokasi saat ini berhasil dideteksi",
        isSuccess: true,
      );
    } else {
      NotificationHelper.showTopNotification(
        context,
        "Tidak dapat mengakses lokasi GPS",
        isSuccess: false,
      );
    }
  }

  // Helper untuk menampilkan error URL
  static void _showUrlError(BuildContext context) {
    NotificationHelper.showTopNotification(
      context,
      "Link Google Maps tidak valid. Gunakan browser untuk mendapatkan link yang benar",
      isSuccess: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/services/location_service.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';

import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class InputOut extends StatefulWidget {
  const InputOut({super.key});

  @override
  State<InputOut> createState() => _InputOutState();
}

class _InputOutState extends State<InputOut> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jamSelesaiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _tanggalController.text =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _jamSelesaiController.text =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _jamSelesaiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = InputDecoration(
      hintStyle: TextStyle(color: AppColors.putih),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.putih),
      ),
    );

    final labelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      color: AppColors.putih,
      fontSize: 16,
    );

    final textStyle = GoogleFonts.poppins(
      color: AppColors.putih,
      fontSize: 14,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            label: "Tanggal",
            hint: "dd / mm / yyyy",
            readOnly: true,
            controller: _tanggalController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: "Jam Keluar",
            hint: "--:--",
            readOnly: true,
            controller: _jamSelesaiController,
            suffixIcon: Icon(Icons.access_time, color: AppColors.putih),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          // === Lokasi ===
          _buildLokasiSection(labelStyle, textStyle, inputStyle),
          const SizedBox(height: 20),
          // === Tombol Submit ===
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitCheckOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasiSection(
      TextStyle labelStyle, TextStyle textStyle, InputDecoration inputStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text("Lokasi", style: labelStyle),
        ),
        TextFormField(
          controller: _lokasiController,
          style: textStyle,
          decoration: inputStyle.copyWith(
            hintText: "Koordinat lokasi Anda",
          ),
          readOnly: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Tombol ambil lokasi
            Expanded(child: _buildAmbilLokasiButton()),
            const SizedBox(width: 12),
            // Tombol lihat peta
            Expanded(child: _buildLihatPetaButton()),
          ],
        ),
      ],
    );
  }

  Widget _buildAmbilLokasiButton() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.8),
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );

            final position = await LocationService.getCurrentPosition();
            Navigator.pop(context);

            if (!mounted) return;

            if (position == null) {
              NotificationHelper.showTopNotification(
                context,
                "GPS mati atau izin ditolak",
                isSuccess: false,
              );
              return;
            }

            setState(() {
              _lokasiController.text =
                  "${position.latitude}, ${position.longitude}";
            });

            HapticFeedback.lightImpact();
            NotificationHelper.showTopNotification(
              context,
              "Lokasi berhasil didapatkan",
              isSuccess: true,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.my_location, color: AppColors.putih, size: 18),
              const SizedBox(width: 8),
              Text(
                "Ambil Lokasi",
                style: GoogleFonts.poppins(
                  color: AppColors.putih,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLihatPetaButton() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.putih.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_lokasiController.text.isEmpty) {
              NotificationHelper.showTopNotification(
                context,
                "Ambil lokasi terlebih dahulu",
                isSuccess: false,
              );
              return;
            }
            try {
              final parts = _lokasiController.text.split(',');
              final lat = double.parse(parts[0].trim());
              final lng = double.parse(parts[1].trim());
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 1.0,
                  expand: false,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Konten bisa discroll
                          Column(
                            children: [
                              // Handle bar
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                height: 5,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const Text(
                                "Lokasi Absen",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Map full tinggi fix
                              Expanded(
                                child: MapPageModal(target: LatLng(lat, lng)),
                              ),

                              const SizedBox(
                                  height: 200), // dummy biar bisa full drag
                            ],
                          ),

                          // Card info nempel di bawah
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LocationInfoCard(
                                target: LatLng(lat, lng),
                                mapController: MapController(),
                                onConfirm: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } catch (e) {
              NotificationHelper.showTopNotification(
                context,
                "Format lokasi tidak valid",
                isSuccess: false,
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined,
                  color: AppColors.putih.withOpacity(0.9), size: 18),
              const SizedBox(width: 8),
              Text(
                "Lihat Peta",
                style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCheckOut() async {
    if (_lokasiController.text.isEmpty) {
      if (!mounted) return;
      NotificationHelper.showTopNotification(
        context,
        "Ambil lokasi dulu sebelum submit",
        isSuccess: false,
      );
      return;
    }
    final absenProvider = context.read<AbsenProvider>();
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final parts = _lokasiController.text.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      await absenProvider.checkout(
        lat: lat,
        lng: lng,
        checkoutDate: _tanggalController.text,
        checkoutTime: _jamSelesaiController.text,
      );

      Navigator.pop(context);

      if (!mounted) return;
      final success = absenProvider.lastCheckoutResult?['success'] ?? false;
      final message =
          absenProvider.lastCheckoutResult?['message'] ?? 'Checkout gagal';
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: success,
      );

      // Reset lokasi kalau sukses
      if (success) {
        setState(() {
          _lokasiController.clear();
        });
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Navigator.pop(context);
      if (!mounted) return;
      NotificationHelper.showTopNotification(
        context,
        "Error: ${e.toString().replaceAll('Exception: ', '')}",
        isSuccess: false,
      );
    }
  }
}

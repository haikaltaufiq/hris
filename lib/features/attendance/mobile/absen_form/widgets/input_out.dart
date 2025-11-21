import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/services/location_service.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
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
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _autoFillDateTime();
  }

  /// Request location permission and start tracking
  Future<void> _requestLocationPermission() async {
    final locationStatus = await Permission.location.request();

    if (locationStatus.isGranted) {
      await _startLocationUpdates();
    } else {
      if (!mounted) return;
      final message = context.isIndonesian
          ? "Izin lokasi ditolak. Aktifkan lokasi untuk melanjutkan."
          : "Location permission denied. Enable location to continue.";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
    }
  }

  /// Auto-fill current date and time
  void _autoFillDateTime() {
    final now = DateTime.now();
    _tanggalController.text =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _jamSelesaiController.text =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  /// Start periodic location updates every 3 seconds
  Future<void> _startLocationUpdates() async {
    await _fetchLocation();

    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _fetchLocation();
    });
  }

  /// Fetch current location and update controller
  Future<void> _fetchLocation() async {
    final position = await LocationService.getCurrentPosition();

    if (!mounted) return;

    if (position == null) {
      _lokasiController.text = "";
      final message = context.isIndonesian
          ? "GPS mati atau izin ditolak"
          : "GPS is off or permission denied";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _lokasiController.text = "${position.latitude}, ${position.longitude}";
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
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
            label: context.isIndonesian ? "Tanggal" : "Date",
            hint: "dd / mm / yyyy",
            readOnly: true,
            onTapIcon: () {},
            controller: _tanggalController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: context.isIndonesian ? "Jam Keluar" : "Out Time",
            hint: "--:--",
            onTapIcon: () {},
            readOnly: true,
            controller: _jamSelesaiController,
            suffixIcon: Icon(Icons.access_time, color: AppColors.putih),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          _buildLokasiSection(labelStyle, textStyle, inputStyle),
          const SizedBox(height: 20),
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

  /// Build location section UI
  Widget _buildLokasiSection(
      TextStyle labelStyle, TextStyle textStyle, InputDecoration inputStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            context.isIndonesian ? "Lokasi" : "Location",
            style: labelStyle,
          ),
        ),
        TextFormField(
          controller: _lokasiController,
          style: textStyle,
          decoration: inputStyle.copyWith(
            hintText: context.isIndonesian
                ? "Koordinat lokasi Anda"
                : "Your Location coordinate",
          ),
          readOnly: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: 12),
            Expanded(child: _buildLihatPetaButton()),
          ],
        ),
      ],
    );
  }

  /// Build "See Map" button
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
              final message = context.isIndonesian
                  ? "Ambil lokasi terlebih dahulu"
                  : "Get location first";
              NotificationHelper.showTopNotification(
                context,
                message,
                isSuccess: false,
              );
              return;
            }
            try {
              final parts = _lokasiController.text.split(',');
              final lat = double.parse(parts[0].trim());
              final lng = double.parse(parts[1].trim());
              HapticFeedback.selectionClick();
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.bg,
                isScrollControlled: true,
                builder: (_) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 1.0,
                  expand: false,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
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
                          Column(
                            children: [
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
                              Text(
                                context.isIndonesian
                                    ? "Lokasi Absen"
                                    : "Attend Location",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.putih,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: MapPageModal(target: LatLng(lat, lng)),
                              ),
                              const SizedBox(height: 200),
                            ],
                          ),
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
              final message = context.isIndonesian
                  ? "Format lokasi tidak valid"
                  : "Invalid location format";
              NotificationHelper.showTopNotification(
                context,
                message,
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
                context.isIndonesian ? "Lihat Peta" : "See Map",
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

  /// Submit checkout data
  Future<void> _submitCheckOut() async {
    _locationTimer?.cancel();
    _locationTimer = null;

    if (_lokasiController.text.isEmpty) {
      if (!mounted) return;
      final message = context.isIndonesian
          ? "Ambil lokasi dulu sebelum submit"
          : "Get location first before submitting";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
      return;
    }

    final absenProvider = context.read<AbsenProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.putih),
      ),
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

      if (absenProvider.lastCheckoutResult?['success'] == true) {
        final message =
            context.isIndonesian ? "Checkout berhasil" : "Checkout success";
        NotificationHelper.showTopNotification(
          context,
          absenProvider.lastCheckoutResult?['message'] ?? message,
          isSuccess: true,
        );
        Navigator.of(context).pop(true);
        setState(() {
          _lokasiController.clear();
        });
      } else {
        final message =
            context.isIndonesian ? "Checkout gagal" : "Checkout failed";
        NotificationHelper.showTopNotification(
          context,
          absenProvider.lastCheckoutResult?['message'] ?? message,
          isSuccess: false,
        );
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

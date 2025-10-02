// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/user_service.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/info_kantor/location_dialog.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class TugasInput extends StatefulWidget {
  const TugasInput({super.key});

  @override
  State<TugasInput> createState() => _TugasInputState();
}

class _TugasInputState extends State<TugasInput> {
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalSelesaiController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _judulTugasController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  UserModel? _selectedUser;
  List<UserModel> _userList = [];
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final userData = await UserService.fetchUsersTugas();
      if (mounted) {
        setState(() {
          _userList = userData;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print("Error fetch users: $e");
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
        NotificationHelper.showTopNotification(
          context,
          'Gagal memuat data user: $e',
          isSuccess: false,
        );
      }
    }
  }

  bool _isValidCoordinate(String lat, String lng) {
    if (lat.isEmpty || lng.isEmpty) return false;

    try {
      final latitude = double.parse(lat);
      final longitude = double.parse(lng);

      // Validasi range koordinat yang valid
      return latitude >= -90 &&
          latitude <= 90 &&
          longitude >= -180 &&
          longitude <= 180;
    } catch (e) {
      return false;
    }
  }

  void _lihatMap() {
    if (!_isValidCoordinate(
        _latitudeController.text, _longitudeController.text)) {
      NotificationHelper.showTopNotification(
        context,
        "Koordinat tidak valid. Harap isi latitude (-90 sampai 90) dan longitude (-180 sampai 180)",
        isSuccess: false,
      );
      return;
    }

    try {
      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);
      final targetLocation = LatLng(latitude, longitude);

      if (context.isMobile) {
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Text(
                          context.isIndonesian
                              ? "Lokasi Tugas"
                              : "Task Location",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Map container
                        Expanded(
                          child: MapPageModal(
                            target: targetLocation,
                          ),
                        ),
                        const SizedBox(height: 200),
                      ],
                    ),

                    // Info card di bawah
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LocationInfoCard(
                          target: targetLocation,
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
      } else {
        Navigator.pushNamed(
          context,
          AppRoutes.mapPage,
          arguments: targetLocation,
        );
      }
    } catch (e) {
      print("Error showing map: $e");
      NotificationHelper.showTopNotification(
        context,
        context.isIndonesian
            ? "Gagal membuka map: ${e.toString()}"
            : "Failed to open the map ${e.toString()}",
        isSuccess: false,
      );
    }
  }

  void _onTapIconDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1F1F1F),
              onPrimary: Colors.white,
              onSurface: AppColors.hitam,
              secondary: AppColors.yellow,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hitam,
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme.apply(
                    bodyColor: AppColors.hitam,
                    displayColor: AppColors.hitam,
                  ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      controller.text =
          "${pickedDate.day.toString().padLeft(2, '0')} / ${pickedDate.month.toString().padLeft(2, '0')} / ${pickedDate.year}";
    }
  }

  @override
  void dispose() {
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _noteController.dispose();
    _judulTugasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tugasProvider = context.watch<TugasProvider>();
    final isLoading = tugasProvider.isLoading;

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
        vertical: MediaQuery.of(context).size.height *
            (context.isMobile ? 0.05 : 0.05),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            hint: context.isIndonesian
                ? "Masukkan judul tugas"
                : "Input task title",
            label: context.isIndonesian ? "Judul Tugas" : "Title",
            controller: _judulTugasController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),

          CustomInputField(
            label: context.isIndonesian ? "Tanggal Mulai" : "Start Date",
            hint: "dd / mm / yyyy",
            controller: _tanggalMulaiController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            onTapIcon: () => _onTapIconDate(_tanggalMulaiController),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),

          CustomInputField(
            label: context.isIndonesian
                ? "Batas Tanggal Penyelesaian"
                : "Deadline Task",
            hint: "dd / mm / yyyy",
            controller: _tanggalSelesaiController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            onTapIcon: () => _onTapIconDate(_tanggalSelesaiController),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),

          // User selection
          _isLoadingUser
              ? const Center(child: CircularProgressIndicator())
              : CustomDropDownField(
                  label: context.isIndonesian ? 'Karyawan' : "Employee",
                  hint: context.isIndonesian ? 'Pilih user' : "Choose user",
                  items: _userList
                      .where((u) => u.nama.isNotEmpty)
                      .map((u) => u.nama)
                      .toList(),
                  value: _selectedUser?.nama,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedUser =
                            _userList.firstWhere((u) => u.nama == val);
                      });
                    }
                  },
                  labelStyle: labelStyle,
                  textStyle: textStyle,
                  dropdownColor: AppColors.secondary,
                  dropdownTextColor: AppColors.putih,
                  dropdownIconColor: AppColors.putih,
                  inputStyle: inputStyle,
                ),
          CustomInputField(
            hint: context.isIndonesian
                ? "Catatan tambahan (opsional)"
                : "Additional note (optional)",
            label: "Note",
            controller: _noteController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),

          CustomInputField(
            hint: "Radius (meter)",
            label: "Radius",
            controller: _radiusController,
            keyboardType: TextInputType.number,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),

          // Location fields
          Row(
            children: [
              Expanded(
                child: CustomInputField(
                  hint: "Latitude",
                  label: context.isIndonesian ? "Lokasi" : "Location",
                  controller: _latitudeController,
                  labelStyle: labelStyle,
                  textStyle: textStyle,
                  inputStyle: inputStyle,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomInputField(
                  hint: "Longitude",
                  label: "",
                  controller: _longitudeController,
                  labelStyle: labelStyle,
                  textStyle: textStyle,
                  inputStyle: inputStyle,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            LocationDialogService.showLocationDialog(
                              context: context,
                              latitudeController: _latitudeController,
                              longitudeController: _longitudeController,
                            );
                          },
                    icon: Icon(
                      Icons.my_location,
                      color: AppColors.putih,
                      size: 18,
                    ),
                    label: Text(
                      context.isIndonesian
                          ? "Bagikan Lokasi"
                          : "Share Location",
                      style: GoogleFonts.poppins(
                        color: AppColors.putih,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.putih,
                      elevation: 0,
                      side: BorderSide(
                        color: AppColors.putih.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _lihatMap,
                    icon: Icon(
                      Icons.map,
                      color: AppColors.putih,
                      size: 18,
                    ),
                    label: Text(
                      context.isIndonesian ? "Lihat Map" : "See Map",
                      style: GoogleFonts.poppins(
                        color: AppColors.putih,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.putih,
                      elevation: 0,
                      side: BorderSide(
                        color: AppColors.putih.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validasi input
                      if (_judulTugasController.text.trim().isEmpty ||
                          _tanggalMulaiController.text.trim().isEmpty ||
                          _tanggalSelesaiController.text.trim().isEmpty ||
                          _selectedUser == null ||
                          _latitudeController.text.trim().isEmpty ||
                          _longitudeController.text.trim().isEmpty) {
                        NotificationHelper.showTopNotification(
                          context,
                          'Harap isi semua data wajib',
                          isSuccess: false,
                        );
                        return;
                      }

                      // Validasi koordinat
                      if (!_isValidCoordinate(_latitudeController.text.trim(),
                          _longitudeController.text.trim())) {
                        NotificationHelper.showTopNotification(
                          context,
                          'Koordinat tidak valid. Gunakan tombol "Bagikan Lokasi" untuk mendapatkan koordinat',
                          isSuccess: false,
                        );
                        return;
                      }

                      try {
                        final latitude = double.tryParse(_latitudeController.text.trim());
                        final longitude = double.tryParse(_longitudeController.text.trim());
                        final radius = int.tryParse(_radiusController.text.trim()) ?? 100;

                        if (latitude == null || longitude == null) {
                          NotificationHelper.showTopNotification(
                            context,
                            'Koordinat tidak valid',
                            isSuccess: false,
                          );
                          return;
                        }

                        final result = await tugasProvider.createTugas(
                          judul: _judulTugasController.text.trim(),
                          tanggalMulai: _tanggalMulaiController.text.trim(),
                          tanggalSelesai: _tanggalSelesaiController.text.trim(),
                          tugasLat: latitude,
                          tugasLng: longitude,
                          person: _selectedUser?.id,
                          note: _noteController.text.trim(),
                          radius: radius,
                        );

                        if (!mounted) return;

                        NotificationHelper.showTopNotification(
                          context,
                          result['message'] ?? 'Terjadi kesalahan',
                          isSuccess: result['success'] ?? false,
                        );

                        if (result['success'] == true) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        print("Error creating task: $e");
                        if (mounted) {
                          NotificationHelper.showTopNotification(
                            context,
                            'Gagal membuat tugas: ${e.toString()}',
                            isSuccess: false,
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                padding: EdgeInsets.symmetric(
                  vertical: context.isMobile ? 18 : 25,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
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
}

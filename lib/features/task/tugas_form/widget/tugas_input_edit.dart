// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/components/timepicker/time_picker.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/user_service.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/info_kantor/location_dialog.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class TugasInputEdit extends StatefulWidget {
  final TugasModel tugas;
  const TugasInputEdit({super.key, required this.tugas});

  @override
  State<TugasInputEdit> createState() => _TugasInputEditState();
}

class _TugasInputEditState extends State<TugasInputEdit> {
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalSelesaiController =
      TextEditingController();
  final TextEditingController _jamMulaiController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _judulTugasController = TextEditingController();

  int _selectedMinute = 0;
  int _selectedHour = 0;
  UserModel? _selectedUser;
  List<UserModel> _userList = [];
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    // Isi controller dari data awal
    _judulTugasController.text = widget.tugas.namaTugas;
    // Jam dari API (HH:mm:ss) → Form (HH:mm)
    if (widget.tugas.jamMulai.isNotEmpty) {
      final parts = widget.tugas.jamMulai.split(':');
      if (parts.length >= 2) {
        _jamMulaiController.text =
            "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
      }
    }
    // Tanggal dari API (yyyy-MM-dd) → Form (dd / MM / yyyy)
    if (widget.tugas.tanggalMulai.isNotEmpty) {
      final parts = widget.tugas.tanggalMulai.split('-');
      if (parts.length == 3) {
        _tanggalMulaiController.text =
            "${parts[2].padLeft(2, '0')} / ${parts[1].padLeft(2, '0')} / ${parts[0]}";
      }
    }
    if (widget.tugas.tanggalSelesai.isNotEmpty) {
      final parts = widget.tugas.tanggalSelesai.split('-');
      if (parts.length == 3) {
        _tanggalSelesaiController.text =
            "${parts[2].padLeft(2, '0')} / ${parts[1].padLeft(2, '0')} / ${parts[0]}";
      }
    }
    if (widget.tugas.lokasi.isNotEmpty) {
      final parts = widget.tugas.lokasi.split(',');
      if (parts.length == 2) {
        _latitudeController.text = parts[0].trim();
        _longitudeController.text = parts[1].trim();
      }
    }
    _noteController.text = widget.tugas.note;

    // user yang sudah ada
    _selectedUser = widget.tugas.user;

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
        setState(() => _isLoadingUser = false);
      }
    }
  }

  void _onTapIconTime(TextEditingController controller) async {
    showModalBottomSheet(
      backgroundColor: AppColors.primary,
      useRootNavigator: true,
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              children: [
                const SizedBox(height: 10),
                ListTile(
                  title: Center(
                    child: Column(
                      children: [
                        Container(
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.isIndonesian ? 'Pilih Waktu' : 'Choose Time',
                          style: TextStyle(
                            color: AppColors.putih,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          context.isIndonesian ? 'Mulai Tugas' : 'Start Task',
                          style: TextStyle(
                            color: AppColors.putih,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                NumberPickerWidget(
                  hour: _selectedHour,
                  minute: _selectedMinute,
                  onHourChanged: (value) {
                    setModalState(() {
                      _selectedHour = value;
                    });
                  },
                  onMinuteChanged: (value) {
                    setModalState(() {
                      _selectedMinute = value;
                    });
                  },
                ),
                FloatingActionButton.extended(
                  backgroundColor: AppColors.secondary,
                  onPressed: () {
                    final formattedHour =
                        _selectedHour.toString().padLeft(2, '0');
                    final formattedMinute =
                        _selectedMinute.toString().padLeft(2, '0');
                    final formattedTime = "$formattedHour:$formattedMinute";
                    controller.text = formattedTime;
                    Navigator.pop(context);
                  },
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      context.isIndonesian ? 'Simpan' : 'Save',
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        color: AppColors.putih,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
              style: TextButton.styleFrom(foregroundColor: AppColors.hitam),
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
        context.isIndonesian
            ? "Koordinat tidak valid. Harap isi latitude (-90 sampai 90) dan longitude (-180 sampai 180)"
            : "Invalid coordinates. Please enter a latitude (-90 to 90) and longitude (-180 to 180).",
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
            : "Failed Open map : ${e.toString()}",
        isSuccess: false,
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_judulTugasController.text.isEmpty ||
        _jamMulaiController.text.isEmpty ||
        _tanggalMulaiController.text.isEmpty ||
        _tanggalSelesaiController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty ||
        _selectedUser == null) {
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          context.isIndonesian
              ? "Harap isi semua data"
              : "Please Fill all the data",
          isSuccess: false,
        );
      }
      return;
    }
// Validasi koordinat
    if (!_isValidCoordinate(
        _latitudeController.text.trim(), _longitudeController.text.trim())) {
      NotificationHelper.showTopNotification(
        context,
        context.isIndonesian
            ? 'Koordinat tidak valid. Gunakan tombol "Bagikan Lokasi" untuk mendapatkan koordinat'
            : "Invalid coordinates. Use the 'Share Location' button to get the coordinates.",
        isSuccess: false,
      );
      return;
    }
    try {
      final tugasProvider = context.read<TugasProvider>();

      final result = await tugasProvider.updateTugas(
        id: widget.tugas.id,
        judul: _judulTugasController.text,
        jamMulai: _jamMulaiController.text,
        tanggalMulai: _tanggalMulaiController.text,
        tanggalSelesai: _tanggalSelesaiController.text,
        person: _selectedUser?.id,
        lokasi:
            "${_latitudeController.text.trim()},${_longitudeController.text.trim()}",
        note: _noteController.text,
      );

      if (!mounted) return;

      final bool isSuccess = result['success'] == true;
      final String message = result['message'] ?? '';

      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: isSuccess,
      );

      if (isSuccess) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          context.isIndonesian ? 'Terjadi kesalahan: $e' : 'Something Wrong $e',
          isSuccess: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _judulTugasController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    _jamMulaiController.dispose();
    _noteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TugasProvider>(
      builder: (context, tugasProvider, child) {
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
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: context.isIndonesian ? "Judul Tugas" : "Title",
                controller: _judulTugasController,
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
                hint: '',
              ),
              CustomInputField(
                label: context.isIndonesian ? "Jam Mulai" : "Start Time",
                hint: "--:--",
                controller: _jamMulaiController,
                suffixIcon: Icon(Icons.access_time, color: AppColors.putih),
                onTapIcon: () => _onTapIconTime(_jamMulaiController),
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
                    : "Deadline Date",
                hint: "dd / mm / yyyy",
                controller: _tanggalSelesaiController,
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
                onTapIcon: () => _onTapIconDate(_tanggalSelesaiController),
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              const SizedBox(height: 10),
              _isLoadingUser
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.putih))
                  : CustomDropDownField(
                      label: context.isIndonesian ? 'Karyawan' : 'Employee',
                      hint: context.isIndonesian ? 'Pilih user' : 'Choose user',
                      items: _userList
                          .map((user) => user.nama)
                          .where((name) => name.isNotEmpty)
                          .toList(),
                      value: _selectedUser?.nama,
                      onChanged: (val) {
                        setState(() {
                          _selectedUser = _userList.firstWhere(
                            (user) => user.nama == val,
                            orElse: () => _userList.first,
                          );
                        });
                      },
                      labelStyle: labelStyle,
                      textStyle: textStyle,
                      dropdownColor: AppColors.secondary,
                      dropdownTextColor: AppColors.putih,
                      dropdownIconColor: AppColors.putih,
                      inputStyle: inputStyle,
                    ),

              CustomInputField(
                label: context.isIndonesian ? 'Catatan' : "Note",
                controller: _noteController,
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
                hint: '',
              ),

              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      key: const ValueKey("latitude_field"),
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
                      key: const ValueKey("longitude_field"),
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
                          context.isIndonesian ? "Lihat Map" : "See Location",
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1F1F),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor:
                        const Color(0xFF1F1F1F).withOpacity(0.6),
                  ),
                  child: isLoading
                      ? const SizedBox(child: CircularProgressIndicator())
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
      },
    );
  }
}

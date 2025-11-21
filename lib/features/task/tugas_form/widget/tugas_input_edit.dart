// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/tugas_service.dart';
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
  final TextEditingController _tanggalPenugasanController =
      TextEditingController();
  final TextEditingController _batasPenugasanController =
      TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _judulTugasController = TextEditingController();

  UserModel? _selectedUser;
  List<UserModel> _userList = [];
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    // Isi controller dari data awal
    _judulTugasController.text = widget.tugas.namaTugas;
    _radiusController.text = widget.tugas.radius.toString();

    // tanggal
    if (widget.tugas.tanggalPenugasan.isNotEmpty) {
      try {
        final date = DateTime.parse(widget.tugas.tanggalPenugasan).toLocal();
        _tanggalPenugasanController.text =
            "${date.day.toString().padLeft(2, '0')}/"
            "${date.month.toString().padLeft(2, '0')}/"
            "${date.year} "
            "${date.hour.toString().padLeft(2, '0')}:"
            "${date.minute.toString().padLeft(2, '0')}";
      } catch (_) {
        _tanggalPenugasanController.text = '';
      }
    }

    if (widget.tugas.batasPenugasan.isNotEmpty) {
      try {
        final date = DateTime.parse(widget.tugas.batasPenugasan).toLocal();
        _batasPenugasanController.text =
            "${date.day.toString().padLeft(2, '0')}/"
            "${date.month.toString().padLeft(2, '0')}/"
            "${date.year} "
            "${date.hour.toString().padLeft(2, '0')}:"
            "${date.minute.toString().padLeft(2, '0')}";
      } catch (_) {
        _batasPenugasanController.text = '';
      }
    }

    if (widget.tugas.tugasLat != null && widget.tugas.tugasLng != null) {
      _latitudeController.text = widget.tugas.tugasLat!.toString();
      _longitudeController.text = widget.tugas.tugasLng!.toString();
    }
    _noteController.text = widget.tugas.note ?? '';

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
      // print("Error fetch users: $e");
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  void _onTapDateandTime(TextEditingController controller) async {
    // Pilih tanggal
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1F1F1F), // header & tanggal terpilih
              onPrimary: Colors.white, // teks tanggal terpilih
              onSurface: AppColors.hitam, // teks hari/bulan
              secondary: AppColors.yellow, // highlight hover
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hitam, // tombol OK & CANCEL
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

    if (pickedDate == null || !mounted) return;

    // Pilih waktu
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: Theme(
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
          ),
        );
      },
    );

    if (pickedTime == null) return;

    // Gabungkan tanggal & waktu
    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Simpan ke controller
    controller.text = "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
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
    final isIndonesian = context.read<LanguageProvider>().isIndonesian;

    if (!_isValidCoordinate(
        _latitudeController.text, _longitudeController.text)) {
      NotificationHelper.showTopNotification(
        context,
        isIndonesian
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
                decoration: BoxDecoration(
                  color: AppColors.primary,
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
                              color: AppColors.putih),
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
      // print("Error showing map: $e");
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
    final isIndonesian = context.read<LanguageProvider>().isIndonesian;

    if (_judulTugasController.text.isEmpty ||
        _tanggalPenugasanController.text.isEmpty ||
        _batasPenugasanController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty ||
        _selectedUser == null) {
      NotificationHelper.showTopNotification(
        context,
        isIndonesian ? "Harap isi semua data" : "Please Fill all the data",
        isSuccess: false,
      );
      return;
    }

    if (!_isValidCoordinate(
        _latitudeController.text.trim(), _longitudeController.text.trim())) {
      NotificationHelper.showTopNotification(
        context,
        isIndonesian ? 'Koordinat tidak valid.' : "Invalid coordinates.",
        isSuccess: false,
      );
      return;
    }

    final tanggalFormatted =
        TugasService.formatDateForApi(_tanggalPenugasanController.text.trim());
    final batasFormatted =
        TugasService.formatDateForApi(_batasPenugasanController.text.trim());

    try {
      // ✅ Simpan user lama SEBELUM update

      final userLamaId = widget.tugas.user?.id;
      final userBaruId = _selectedUser?.id;

      final tugasProvider = context.read<TugasProvider>();
      final latitude = double.tryParse(_latitudeController.text.trim());
      final longitude = double.tryParse(_longitudeController.text.trim());
      final radiusText = _radiusController.text.trim();
      final radius = int.tryParse(radiusText);
      if (radius == null) {
        final message = context.isIndonesian
            ? 'Radius harus berupa angka'
            : 'Radius must be a number';
        NotificationHelper.showTopNotification(
          context,
          message,
          isSuccess: false,
        );
        return; // hentikan proses kalau invalid
      }

      final result = await tugasProvider.updateTugas(
        id: widget.tugas.id,
        judul: _judulTugasController.text.trim(),
        tanggalPenugasan: tanggalFormatted,
        batasPenugasan: batasFormatted,
        tugasLat: latitude!,
        tugasLng: longitude!,
        person: userBaruId,
        note: _noteController.text.trim(),
        radius: radius,
      );

      if (!mounted) return;

      final bool isSuccess = result['success'] == true;
      final String message = result['message'] ?? '';

      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: isSuccess,
      );

      if (isSuccess && mounted) {
        // 1) Update cache lokal segera supaya countdown baca data baru
        if (userBaruId != userLamaId) {
          print('⚠️ PIC berubah: $userLamaId -> $userBaruId');
          print('✅ Backend akan kirim notifikasi terpisah:');
          print('   - User lama ($userLamaId): tugas_pindah');
          print('   - User baru ($userBaruId): tugas_baru');
        } else {
          print(
              '✅ PIC tidak berubah, backend kirim tugas_update ke User $userBaruId');
        }

        try {
          final box = Hive.box('tugas');
          await box.put('batas_penugasan_${widget.tugas.id}', batasFormatted);
          // set flag untuk background worker bila perlu
          await box.put('update_needed_${widget.tugas.id}', true);
          print('✅ Hive cache berhasil diupdate');
        } catch (e) {
          // log, tapi jangan ganggu alur success
          print('Gagal update Hive batas_penugasan: $e');
        }

        // 2) Stop countdown lama dan start countdown baru
        // try {
        //   final countdownSvc =
        //       CountdownNotificationService(flutterLocalNotificationsPlugin);
        //   await countdownSvc.stopCountdown(tugasId: widget.tugas.id);
        //   final batasDate = DateTime.parse(batasFormatted);
        //   countdownSvc.startCountdown(
        //       batasDate, _judulTugasController.text.trim(), widget.tugas.id);
        // } catch (e) {
        //   print('⚠️ Gagal restart countdown: $e');
        // }
        print('✅ Menunggu FCM notification untuk restart countdown...');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          isIndonesian ? 'Terjadi kesalahan: $e' : 'Something Wrong: $e',
          isSuccess: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _judulTugasController.dispose();
    _tanggalPenugasanController.dispose();
    _batasPenugasanController.dispose();
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
                label: context.isIndonesian ? "Tanggal Mulai" : "Start Date",
                hint: "dd / mm / yyyy",
                controller: _tanggalPenugasanController,
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
                onTapIcon: () => _onTapDateandTime(_tanggalPenugasanController),
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              CustomInputField(
                label: context.isIndonesian
                    ? "Batas Tanggal Penyelesaian"
                    : "Deadline Date",
                hint: "dd / mm / yyyy",
                controller: _batasPenugasanController,
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
                onTapIcon: () => _onTapDateandTime(_batasPenugasanController),
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

              const SizedBox(height: 10),

              CustomInputField(
                label:
                    context.isIndonesian ? 'Radius (meter)' : 'Radius (meter)',
                hint: 'Masukkan radius tugas',
                controller: _radiusController,
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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

// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/data/services/tugas_service.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class UserEditTugas extends StatefulWidget {
  final TugasModel tugas;
  const UserEditTugas({super.key, required this.tugas});

  @override
  State<UserEditTugas> createState() => _UserEditTugasState();
}

class _UserEditTugasState extends State<UserEditTugas> {
  final TextEditingController _tanggalPenugasanController =
      TextEditingController();
  final TextEditingController _batasPenugasanController =
      TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _judulTugasController = TextEditingController();
  final TextEditingController _lampiranTugasController =
      TextEditingController();
  final TextEditingController _latitudeUploadController =
      TextEditingController();
  final TextEditingController _longitudeUploadController =
      TextEditingController();

  File? _selectedFile;
  Uint8List? _selectedBytes;
  String? _selectedFileName;
  bool _isTrackingLocation = false;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _judulTugasController.text = widget.tugas.namaTugas;
    _lokasiController.text = widget.tugas.displayLokasiTugas;

    _noteController.text = widget.tugas.note ?? '';

    // Tanggal dari API (yyyy-MM-dd) → Form (dd / MM / yyyy)
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

    // Load existing lampiran location if available
    if (widget.tugas.lampiranLat != null && widget.tugas.lampiranLng != null) {
      _latitudeUploadController.text = widget.tugas.lampiranLat.toString();
      _longitudeUploadController.text = widget.tugas.lampiranLng.toString();
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

  Future<void> _trackCurrentLocation() async {
    setState(() {
      _isTrackingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          NotificationHelper.showTopNotification(
            context,
            context.isIndonesian
                ? 'GPS tidak aktif. Mohon aktifkan GPS Anda'
                : 'GPS is not enabled. Please enable your GPS',
            isSuccess: false,
          );
        }
        setState(() {
          _isTrackingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            NotificationHelper.showTopNotification(
              context,
              context.isIndonesian
                  ? 'Izin lokasi ditolak'
                  : 'Location permission denied',
              isSuccess: false,
            );
          }
          setState(() {
            _isTrackingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          NotificationHelper.showTopNotification(
            context,
            context.isIndonesian
                ? 'Izin lokasi ditolak permanen. Mohon aktifkan di pengaturan'
                : 'Location permission permanently denied. Please enable in settings',
            isSuccess: false,
          );
        }
        setState(() {
          _isTrackingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeUploadController.text = position.latitude.toString();
        _longitudeUploadController.text = position.longitude.toString();
        _isTrackingLocation = false;
      });

      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          context.isIndonesian
              ? 'Lokasi berhasil di-track'
              : 'Location tracked successfully',
          isSuccess: true,
        );
      }
    } catch (e) {
      // print("Error tracking location: $e");
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          context.isIndonesian
              ? 'Gagal mendapatkan lokasi: ${e.toString()}'
              : 'Failed to get location: ${e.toString()}',
          isSuccess: false,
        );
      }
      setState(() {
        _isTrackingLocation = false;
      });
    }
  }

  void _lihatMap() {
    if (!_isValidCoordinate(
        _latitudeUploadController.text, _longitudeUploadController.text)) {
      NotificationHelper.showTopNotification(
        context,
        context.isIndonesian
            ? "Koordinat tidak valid. Harap track lokasi terlebih dahulu"
            : "Invalid coordinates. Please track location first",
        isSuccess: false,
      );
      return;
    }

    try {
      final latitude = double.parse(_latitudeUploadController.text);
      final longitude = double.parse(_longitudeUploadController.text);
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
                              ? "Lokasi Upload"
                              : "Upload Location",
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
      // print("Error showing map: $e");
      NotificationHelper.showTopNotification(
        context,
        context.isIndonesian
            ? "Gagal membuka map: ${e.toString()}"
            : "Failed to open the map ${e.toString()}",
        isSuccess: false,
      );
    }
  }

  Future<void> _handleSubmit() async {
    if ((!kIsWeb && _selectedFile == null) ||
        (kIsWeb && _selectedBytes == null)) {
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          context.isIndonesian
              ? "Harap upload lampiran"
              : "Please Upload the Attachment",
          isSuccess: false,
        );
      }
      return;
    }

    // Validasi koordinat upload location
    if (!_isValidCoordinate(_latitudeUploadController.text.trim(),
        _longitudeUploadController.text.trim())) {
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          context.isIndonesian
              ? 'Koordinat lokasi upload tidak valid. Gunakan tombol "Track Lokasi" untuk mendapatkan koordinat'
              : 'Upload location coordinates are invalid. Use "Track Location" button to get coordinates',
          isSuccess: false,
        );
      }
      return;
    }

    try {
      final latitude = double.tryParse(_latitudeUploadController.text.trim());
      final longitude = double.tryParse(_longitudeUploadController.text.trim());

      if (latitude == null || longitude == null) {
        if (mounted) {
          NotificationHelper.showTopNotification(
            context,
            context.isIndonesian
                ? 'Koordinat tidak valid'
                : 'Invalid coordinates',
            isSuccess: false,
          );
        }
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final resultUpload = await TugasService.uploadFileTugas(
        id: widget.tugas.id,
        file: kIsWeb ? null : _selectedFile,
        fileBytes: kIsWeb ? _selectedBytes : null,
        fileName: kIsWeb ? _selectedFileName : null,
        lampiranLat: latitude,
        lampiranLng: longitude,
      );

      final bool isSuccess = resultUpload['success'] == true;
      final String message = resultUpload['message'] ?? '';

      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          message,
          isSuccess: isSuccess,
        );
      }

      if (isSuccess && mounted) {
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _judulTugasController.dispose();
    _tanggalPenugasanController.dispose();
    _batasPenugasanController.dispose();
    _noteController.dispose();
    _lokasiController.dispose();
    _lampiranTugasController.dispose();
    _latitudeUploadController.dispose();
    _longitudeUploadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TugasProvider>(
      builder: (context, tugasProvider, child) {
        final isLoading = tugasProvider.isLoading || _isSubmitting;

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
                onTapIcon: () {
                  NotificationHelper.showTopNotification(
                      context,
                      context.isIndonesian
                          ? "Anda tidak dapat mengubah judul"
                          : "You can't change the title",
                      isSuccess: false);
                },
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
                onTapIcon: () {
                  NotificationHelper.showTopNotification(
                      context,
                      context.isIndonesian
                          ? "Anda tidak dapat mengubah tanggal"
                          : "You can't change the date",
                      isSuccess: false);
                },
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              CustomInputField(
                label: context.isIndonesian
                    ? "Batas Tanggal Penyelesaian"
                    : "Deadline Task",
                hint: "dd / mm / yyyy",
                controller: _batasPenugasanController,
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
                onTapIcon: () {
                  NotificationHelper.showTopNotification(
                      context,
                      context.isIndonesian
                          ? "Anda tidak dapat mengubah tanggal"
                          : "You can't change the date",
                      isSuccess: false);
                },
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              // CustomInputField(
              //   label: "Lokasi",
              //   controller: _lokasiController,
              //   onTapIcon: () {
              //     NotificationHelper.showTopNotification(
              //         context,
              //         context.isIndonesian
              //             ? "Anda tidak dapat mengubah lokasi"
              //             : "You can't change the location",
              //         isSuccess: false);
              //   },
              //   labelStyle: labelStyle,
              //   textStyle: textStyle,
              //   inputStyle: inputStyle,
              //   hint: '',
              // ),
              CustomInputField(
                label: "Note",
                controller: _noteController,
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
                hint: '',
              ),
              CustomInputField(
                label: context.isIndonesian ? "Lampiran" : "Attachment",
                suffixIcon: Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(width: 1, color: AppColors.putih)),
                  child: Center(
                    child: Text(
                      context.isIndonesian ? "Pilih File" : "Choose File",
                      style: TextStyle(color: AppColors.putih),
                    ),
                  ),
                ),
                onTapIcon: () async {
                  try {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(type: FileType.any);

                    if (result != null && result.files.isNotEmpty) {
                      if (kIsWeb) {
                        final bytes = result.files.first.bytes;
                        if (bytes != null) {
                          setState(() {
                            _selectedBytes = bytes;
                            _selectedFileName = result.files.first.name;
                            _lampiranTugasController.text =
                                result.files.first.name;
                          });
                        }
                      } else {
                        final filePath = result.files.single.path;
                        if (filePath != null) {
                          setState(() {
                            _selectedFile = File(filePath);
                            _lampiranTugasController.text =
                                filePath.split('/').last;
                          });
                        }
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      NotificationHelper.showTopNotification(
                        context,
                        context.isIndonesian
                            ? 'Gagal pilih file: $e'
                            : "Failed to choose file: $e",
                        isSuccess: false,
                      );
                    }
                  }
                },
                controller: _lampiranTugasController,
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
                hint: context.isIndonesian
                    ? 'Upload File Lampiran'
                    : "Upload Attachment File",
              ),

              // Location Upload fields
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      hint: "Latitude",
                      label: context.isIndonesian
                          ? "Lokasi Upload"
                          : "Upload Location",
                      controller: _latitudeUploadController,
                      labelStyle: labelStyle,
                      textStyle: textStyle,
                      onTapIcon: () {},
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
                      controller: _longitudeUploadController,
                      labelStyle: labelStyle,
                      textStyle: textStyle,
                      onTapIcon: () {},
                      inputStyle: inputStyle,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Action buttons (Track Lokasi & Lihat Map)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: (isLoading || _isTrackingLocation)
                            ? null
                            : _trackCurrentLocation,
                        icon: _isTrackingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.my_location,
                                color: AppColors.putih,
                                size: 18,
                              ),
                        label: Text(
                          context.isIndonesian
                              ? "Track Lokasi"
                              : "Track Location",
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
                        onPressed: (isLoading || _isTrackingLocation)
                            ? null
                            : _lihatMap,
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

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (isLoading || _isTrackingLocation) ? null : _handleSubmit,
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
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
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

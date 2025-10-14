// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/data/services/tugas_service.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:provider/provider.dart';

class UserEditTugas extends StatefulWidget {
  final TugasModel tugas;
  const UserEditTugas({super.key, required this.tugas});

  @override
  State<UserEditTugas> createState() => _UserEditTugasState();
}

class _UserEditTugasState extends State<UserEditTugas> {
  final TextEditingController _tanggalPenugasanController = TextEditingController();
  final TextEditingController _batasPenugasanController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _judulTugasController = TextEditingController();
  final TextEditingController _lampiranTugasController =
      TextEditingController();

  File? _selectedFile;
  Uint8List? _selectedBytes;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _judulTugasController.text = widget.tugas.namaTugas;
    _lokasiController.text = widget.tugas.displayLokasiTugas;

    _noteController.text = widget.tugas.note ?? '';

    // Tanggal dari API (yyyy-MM-dd) → Form (dd / MM / yyyy)
    if (widget.tugas.tanggalPenugasan != null &&
        widget.tugas.tanggalPenugasan.isNotEmpty) {
      final parts = widget.tugas.tanggalPenugasan.split('-');
      if (parts.length == 3) {
        _tanggalPenugasanController.text =
            "${parts[2].padLeft(2, '0')} / ${parts[1].padLeft(2, '0')} / ${parts[0]}";
      }
    }
    if (widget.tugas.batasPenugasan != null &&
        widget.tugas.batasPenugasan.isNotEmpty) {
      final parts = widget.tugas.batasPenugasan.split('-');
      if (parts.length == 3) {
        _batasPenugasanController.text =
            "${parts[2].padLeft(2, '0')} / ${parts[1].padLeft(2, '0')} / ${parts[0]}";
      }
    }
  }

  Future<void> _handleSubmit() async {
    if ((!kIsWeb && _selectedFile == null) || (kIsWeb && _selectedBytes == null)) {
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

    try {
      final resultUpload = await TugasService.uploadFileTugas(
        id: widget.tugas.id,
        file: kIsWeb ? null : _selectedFile,
        fileBytes: kIsWeb ? _selectedBytes : null,
        fileName: kIsWeb ? _selectedFileName : null,
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
          context.isIndonesian
              ? 'Terjadi kesalahan: $e'
              : 'Something Wrong $e',
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
    _lokasiController.dispose();
    _lampiranTugasController.dispose();
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
              CustomInputField(
                label: "Lokasi",
                controller: _lokasiController,
                onTapIcon: () {
                  NotificationHelper.showTopNotification(
                      context, "Anda tidak dapat mengubah lokasi",
                      isSuccess: false);
                },
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
                hint: '',
              ),
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
              const SizedBox(height: 10),
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
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

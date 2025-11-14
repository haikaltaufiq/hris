import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cuti_viewmodel/cuti_provider.dart';

class CutiInput extends StatefulWidget {
  const CutiInput({super.key});

  @override
  State<CutiInput> createState() => _CutiInputState();
}

class _CutiInputState extends State<CutiInput> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tipeCutiController = TextEditingController();
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalSelesaiController =
      TextEditingController();
  final TextEditingController _alasanController = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadNamaUser();
  }

  void _loadNamaUser() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('nama') ?? '';
    setState(() {
      _namaController.text = nama;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cutiProvider = context.read<CutiProvider>();

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
            label: context.isIndonesian ? "Nama" : "Name",
            hint: "",
            onTapIcon: () {},
            controller: _namaController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label: context.isIndonesian ? 'Tipe Cuti' : 'Leave Type',
            hint: '',
            items: ['Sakit', 'Izin'],
            labelStyle: labelStyle,
            textStyle: textStyle,
            dropdownColor: AppColors.secondary,
            dropdownTextColor: AppColors.putih,
            dropdownIconColor: AppColors.putih,
            inputStyle: inputStyle,
            onChanged: (String? val) {
              if (val != null) {
                setState(() {
                  _tipeCutiController.text = val;
                });
              }
            },
          ),
          CustomInputField(
            label: context.isIndonesian ? "Tanggal Mulai" : "Start Date",
            hint: "dd / mm / yyyy",
            controller: _tanggalMulaiController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            onTapIcon: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF1F1F1F), // Header & selected date
                        onPrimary: Colors.white, // Teks tanggal terpilih
                        onSurface: AppColors.hitam, // Teks hari/bulan
                        secondary:
                            AppColors.yellow, // Hari yang di-hover / highlight
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.hitam, // Tombol CANCEL/OK
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
                _tanggalMulaiController.text =
                    "${pickedDate.day.toString().padLeft(2, '0')} / ${pickedDate.month.toString().padLeft(2, '0')} / ${pickedDate.year}";
              }
            },
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: context.isIndonesian ? "Tanggal Selesai" : "End Date",
            hint: "dd / mm / yyyy",
            controller: _tanggalSelesaiController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            onTapIcon: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF1F1F1F), // Header & selected date
                        onPrimary: Colors.white, // Teks tanggal terpilih
                        onSurface: AppColors.hitam, // Teks hari/bulan
                        secondary:
                            AppColors.yellow, // Hari yang di-hover / highlight
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.hitam, // Tombol CANCEL/OK
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
                _tanggalSelesaiController.text =
                    "${pickedDate.day.toString().padLeft(2, '0')} / ${pickedDate.month.toString().padLeft(2, '0')} / ${pickedDate.year}";
              }
            },
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: context.isIndonesian ? "Alasan" : "Reason",
            hint: "",
            controller: _alasanController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      // Cek apakah ada field yang kosong
                      if (_namaController.text.isEmpty ||
                          _tipeCutiController.text.isEmpty ||
                          _tanggalMulaiController.text.isEmpty ||
                          _tanggalSelesaiController.text.isEmpty ||
                          _alasanController.text.isEmpty) {
                        final message = context.isIndonesian
                            ? 'Semua field wajib diisi!'
                            : 'All fields are required!';
                        NotificationHelper.showTopNotification(
                          context,
                          message,
                          isSuccess: false,
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final result = await cutiProvider.createCuti(
                          nama: _namaController.text,
                          tipeCuti: _tipeCutiController.text,
                          tanggalMulai: _tanggalMulaiController.text,
                          tanggalSelesai: _tanggalSelesaiController.text,
                          alasan: _alasanController.text,
                        );

                        // ====== JIKA SUKSES ======
                        if (result['success'] == true) {
                          if (context.mounted) {
                            final message = context.isIndonesian
                                ? 'Cuti berhasil diajukan'
                                : 'Leave request submitted successfully';

                            NotificationHelper.showTopNotification(
                              context,
                              message,
                              isSuccess: true,
                            );

                            Navigator.of(context).pop(true);
                          }
                        }

                        // ====== JIKA ERROR ======
                        else {
                          if (context.mounted) {
                            // Ambil pesan dari backend
                            final backendMsg = result['message'];

                            // fallback bila backend tidak punya message
                            final fallback = context.isIndonesian
                                ? 'Gagal mengajukan cuti'
                                : 'Failed to submit leave request';

                            NotificationHelper.showTopNotification(
                              context,
                              backendMsg ?? fallback,
                              isSuccess: false,
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          final message = context.isIndonesian
                              ? 'Terjadi kesalahan: $e'
                              : 'An error occurred: $e';
                          NotificationHelper.showTopNotification(
                            context,
                            message,
                            isSuccess: false,
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.putih,
                        strokeWidth: 2,
                      ),
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
  }
}

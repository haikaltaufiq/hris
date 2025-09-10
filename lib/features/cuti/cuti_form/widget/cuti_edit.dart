// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CutiEdit extends StatefulWidget {
  final CutiModel cuti;

  const CutiEdit({super.key, required this.cuti});

  @override
  State<CutiEdit> createState() => _CutiEditState();
}

class _CutiEditState extends State<CutiEdit> {
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
    _tipeCutiController.text = widget.cuti.tipe_cuti;
    _tanggalMulaiController.text = widget.cuti.tanggal_mulai;
    _tanggalSelesaiController.text = widget.cuti.tanggal_selesai;
    _alasanController.text = widget.cuti.alasan;
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
            label: "Nama",
            hint: "",
            controller: _namaController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label: 'Tipe Cuti',
            hint: '',
            items: ['Tahunan', 'Sakit', 'Unpaid', 'Izin'],
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
            label: "Tanggal Mulai",
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
            label: "Tanggal Selesai",
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
            label: "Alasan",
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
                        NotificationHelper.showTopNotification(
                          context,
                          'Semua field wajib diisi!',
                          isSuccess: false,
                        );
                        return; // stop submit
                      }
                      setState(() => _isLoading = true);
                      try {
                        final result = await cutiProvider.editCuti(
                          id: widget.cuti.id,
                          nama: _namaController.text,
                          tipeCuti: _tipeCutiController.text,
                          tanggalMulai: _tanggalMulaiController.text,
                          tanggalSelesai: _tanggalSelesaiController.text,
                          alasan: _alasanController.text,
                        );

                        NotificationHelper.showTopNotification(
                          context,
                          result['message'],
                          isSuccess: result['success'],
                        );

                        if (result['success']) {
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          NotificationHelper.showTopNotification(
                              context, 'Error: $e',
                              isSuccess: false);
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
                      width: 24,
                      height: 24,
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

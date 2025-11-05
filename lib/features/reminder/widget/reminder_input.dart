// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/services/pengingat_service.dart';
import 'package:hr/data/services/peran_service.dart'; // Import the new service

class ReminderInput extends StatefulWidget {
  const ReminderInput({super.key});

  @override
  State<ReminderInput> createState() => _ReminderInputState();
}

class _ReminderInputState extends State<ReminderInput> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _reminderNameController = TextEditingController();
  final TextEditingController _reminderDeskripsiController =
      TextEditingController();

  PeranModel? _selectedPeran;
  List<PeranModel> _peranList = [];
  bool _isLoadingPeran = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPeran();
  }

  Future<void> _loadPeran() async {
    try {
      final peranData = await PeranService.fetchPeran();
      if (mounted) {
        setState(() {
          _peranList = peranData;
          _isLoadingPeran = false;
        });
      }
    } catch (e) {
      // print("Error fetch roles: $e");
      if (mounted) {
        setState(() {
          _isLoadingPeran = false;
        });
        NotificationHelper.showTopNotification(
          context,
          'Gagal memuat data peran: $e',
          isSuccess: false,
        );
      }
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
    _tanggalController.dispose();
    _reminderNameController.dispose();
    _reminderDeskripsiController.dispose();
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
        vertical: MediaQuery.of(context).size.height *
            (context.isMobile ? 0.05 : 0.05),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            hint: "",
            label: context.isIndonesian ? "Nama Pengingat" : "Reminder Name",
            controller: _reminderNameController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            hint: "",
            label: context.isIndonesian ? "Deskripsi" : "Description",
            controller: _reminderDeskripsiController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: context.isIndonesian ? "Tanggal" : "Date",
            hint: "dd / mm / yyyy",
            controller: _tanggalController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            onTapIcon: () => _onTapIconDate(_tanggalController),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          // Pilih Peran
          // Dropdown peran
          _isLoadingPeran
              ? const Center(child: CircularProgressIndicator())
              : CustomDropDownField(
                  label: 'PIC',
                  hint: context.isIndonesian ? 'Pilih PIC' : 'Choose PIC',
                  // pastiin ini bener-bener list of string
                  items: _peranList.map((p) => p.namaPeran).toList(),
                  value: _selectedPeran?.namaPeran,
                  onChanged: (val) {
                    setState(() {
                      _selectedPeran =
                          _peranList.firstWhere((p) => p.namaPeran == val);
                    });
                  },
                  labelStyle: labelStyle,
                  textStyle: textStyle,
                  dropdownColor: AppColors.secondary,
                  dropdownTextColor: AppColors.putih,
                  dropdownIconColor: AppColors.putih,
                  inputStyle: inputStyle,
                ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_reminderNameController.text.isEmpty ||
                          _tanggalController.text.isEmpty ||
                          _selectedPeran == null) {
                        NotificationHelper.showTopNotification(
                          context,
                          'Harap isi semua data',
                          isSuccess: false,
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        // Format tanggal ke format backend (yyyy-MM-dd HH:mm:ss)
                        final parts = _tanggalController.text.split(" / ");
                        final formattedDate =
                            "${parts[2]}-${parts[1]}-${parts[0]} 00:00:00";

                        final reminder = ReminderData(
                          id: 0, // backend akan isi otomatis
                          judul: _reminderNameController.text,
                          deskripsi: _reminderDeskripsiController
                              .text, // kalau ada field deskripsi tambahin
                          tanggalJatuhTempo: formattedDate,
                          status: "Pending",
                          picId: _selectedPeran!.id, // ambil id dari model
                        );

                        await PengingatService.createPengingat(reminder);

                        if (mounted) {
                          NotificationHelper.showTopNotification(
                            context,
                            'Reminder berhasil ditambahkan',
                            isSuccess: true,
                          );
                          Navigator.pop(context, true);
                          // reset form
                          _reminderNameController.clear();
                          _tanggalController.clear();
                          setState(() {
                            _selectedPeran = null;
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          NotificationHelper.showTopNotification(
                            context,
                            'Gagal menambahkan reminder: $e',
                            isSuccess: false,
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isLoading = false);
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

// ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/services/potongan_gaji_service.dart';

class PotonganEditInput extends StatefulWidget {
  final PotonganGajiModel potongan;

  const PotonganEditInput({super.key, required this.potongan});

  @override
  State<PotonganEditInput> createState() => _PotonganEditInputState();
}

class _PotonganEditInputState extends State<PotonganEditInput> {
  TextEditingController controller = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.potongan.namaPotongan);
    jumlahController =
        TextEditingController(text: widget.potongan.nominal.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    jumlahController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = controller.text.trim();
    final nominalText = jumlahController.text.trim();
    final nominal = double.tryParse(nominalText);

    if (nama.isEmpty) {
      final message = context.isIndonesian
          ? 'Nama potongan harus diisi'
          : 'Deduction name is required';
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
      return;
    }

    if (nominal == null) {
      final message = context.isIndonesian
          ? 'Jumlah potongan harus berupa angka saja'
          : 'Deduction amount must be a number';
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedPotongan = PotonganGajiModel(
      id: widget.potongan.id,
      namaPotongan: nama,
      nominal: nominal,
    );

    try {
      final result =
          await PotonganGajiService.updatePotonganGaji(updatedPotongan);

      if (result['success'] == true) {
        final messages = context.isIndonesian
            ? 'Potongan berhasil diupdate'
            : 'Deduction updated successfully';
        NotificationHelper.showTopNotification(
          context,
          result['message'] ?? messages,
          isSuccess: true,
        );
        Navigator.of(context).pop(true);
      } else {
        final messages = context.isIndonesian
            ? 'Gagal update potongan'
            : 'Failed to update deduction';
        NotificationHelper.showTopNotification(
          context,
          result['message'] ?? messages,
          isSuccess: false,
        );
      }
    } catch (e) {
      final message = context.isIndonesian
          ? 'Terjadi kesalahan: $e'
          : 'An error occurred: $e';
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            hint: "",
            label: context.isIndonesian ? "Nama Potongan" : "Name",
            controller: controller,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            hint: "",
            label: context.isIndonesian
                ? "Jumlah Potongan (%)"
                : "Deduction Amount (%)",
            controller: jumlahController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
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
}

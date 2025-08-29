// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../components/custom/custom_input.dart';
import '../../../../core/helpers/notification_helper.dart';
import '../../../../data/models/potongan_gaji.dart';
import '../../view_model/potongan_gaji_provider.dart';

class PotonganInput extends StatefulWidget {
  const PotonganInput({
    super.key,
  });

  @override
  State<PotonganInput> createState() => _PotonganInputState();
}

class _PotonganInputState extends State<PotonganInput> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  bool _isSubmitting = false;

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
            label: "Nama Potongan",
            controller: controller,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            hint: "",
            label: "Jumlah Potongan",
            controller: jumlahController,
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final name = controller.text.trim();
                      final jumlahText = jumlahController.text.trim();
                      final jumlah = double.tryParse(jumlahText);

                      if (name.isEmpty) {
                        NotificationHelper.showTopNotification(
                          context,
                          'Nama Potongan harus di isi',
                          isSuccess: false,
                        );
                        return;
                      }

                      if (jumlah == null) {
                        NotificationHelper.showTopNotification(
                          context,
                          'Jumlah potongan harus berupa angka',
                          isSuccess: false,
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);

                      try {
                        final provider = context.read<PotonganGajiProvider>();
                        await provider.createPotonganGaji(
                          PotonganGajiModel(
                            id: 0, // id akan di-generate di backend
                            namaPotongan: name,
                            nominal: jumlah,
                          ),
                        );

                        NotificationHelper.showTopNotification(
                          context,
                          'Potongan Berhasil dibuat',
                          isSuccess: true,
                        );
                        Navigator.pop(context);

                        // reset input
                        controller.clear();
                        jumlahController.clear();
                      } catch (e) {
                        NotificationHelper.showTopNotification(
                          context,
                          'Gagal membuat potongan $e',
                          isSuccess: false,
                        );
                      } finally {
                        setState(() => _isSubmitting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
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

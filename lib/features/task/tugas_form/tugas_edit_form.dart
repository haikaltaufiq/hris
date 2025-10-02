import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/task/tugas_form/widget/tugas_input_edit.dart';

class TugasEditForm extends StatefulWidget {
  final TugasModel tugas;

  const TugasEditForm({super.key, required this.tugas});

  @override
  State<TugasEditForm> createState() => _TugasEditFormState();
}

class _TugasEditFormState extends State<TugasEditForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile
          ? AppBar(
              title: Text(
                context.isIndonesian ? 'Perbarui Tugas' : 'Edit Task',
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              backgroundColor: AppColors.bg,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: AppColors.putih,
                onPressed: () => Navigator.of(context).pop(),
              ),
              iconTheme: IconThemeData(
                color: AppColors.putih,
              ),
            )
          : null, // kalau bukan mobile, AppBar di-off
      body: ListView(children: [
        TugasInputEdit(
          tugas: widget.tugas, // <- ambil dari widget
        ),
      ]),
    );
  }
}

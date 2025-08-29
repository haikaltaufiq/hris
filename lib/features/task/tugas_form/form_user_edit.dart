import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/task/tugas_form/widget/user_tugas_edit.dart';

class FormUserEdit extends StatefulWidget {
  final TugasModel tugas;

  const FormUserEdit({super.key, required this.tugas});

  @override
  State<FormUserEdit> createState() => _FormUserEditState();
}

class _FormUserEditState extends State<FormUserEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Upload Lampiran',
          style: TextStyle(
              color: AppColors.putih,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily),
        ),
        backgroundColor: AppColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // atau CupertinoIcons.back
          color: AppColors.putih,
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
          color: AppColors.putih, // warna ikon back
        ),
      ),
      body: ListView(children: [
        UserEditTugas(
          tugas: widget.tugas, // <- ambil dari widget
        ),
      ]),
    );
  }
}

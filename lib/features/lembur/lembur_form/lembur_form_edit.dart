import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/lembur_model.dart';
import 'package:hr/features/lembur/lembur_form/widget/lembur_edit.dart';

class LemburFormEdit extends StatefulWidget {
  final LemburModel lembur;

  const LemburFormEdit({super.key, required this.lembur});

  @override
  State<LemburFormEdit> createState() => _LemburFormEditState();
}

class _LemburFormEditState extends State<LemburFormEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Edit Lembur',
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
        LemburEdit(
          lembur: widget.lembur,
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/features/cuti/cuti_form/widget/cuti_edit.dart';

class CutiEditForm extends StatefulWidget {
  final CutiModel cuti;

  const CutiEditForm({super.key, required this.cuti});

  @override
  State<CutiEditForm> createState() => _CutiEditFormState();
}

class _CutiEditFormState extends State<CutiEditForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Edit Cuti',
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
        CutiEdit(
          cuti: widget.cuti,
        ),
      ]),
    );
  }
}

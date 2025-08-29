import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/features/karyawan/karyawan_form/widget/karyawan_input_edit.dart';

class KaryawanFormEdit extends StatelessWidget {
  final UserModel user;

  const KaryawanFormEdit({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Edit Karyawan',
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
      ),
      body: ListView(
        children: [
          KaryawanInputEdit(
            user: user,
          ),
        ],
      ),
    );
  }
}

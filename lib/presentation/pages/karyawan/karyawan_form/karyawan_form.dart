import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/karyawan/karyawan_form/widget/karyawan_input.dart';

class KaryawanForm extends StatelessWidget {
  const KaryawanForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Daftarkan Karyawan',
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
          KaryawanInput(),
        ],
      ),
    );
  }
}

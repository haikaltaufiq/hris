import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/karyawan/karyawan_form/widget/karyawan_input.dart';

class KaryawanForm extends StatelessWidget {
  const KaryawanForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile
          ? AppBar(
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
              iconTheme: IconThemeData(
                color: AppColors.putih,
              ),
            )
          : null,
      body: ListView(
        children: [
          KaryawanInput(),
        ],
      ),
    );
  }
}

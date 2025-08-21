import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/absen/absen_form/widgets/input_in.dart';

class AbsenMasukPage extends StatefulWidget {
  const AbsenMasukPage({super.key});

  @override
  State<AbsenMasukPage> createState() => _AbsenMasukPageState();
}

class _AbsenMasukPageState extends State<AbsenMasukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Absen Masuk',
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
        InputIn(
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/attendance/mobile/absen_form/widgets/input_out.dart';

class AbsenKeluarPage extends StatefulWidget {
  const AbsenKeluarPage({super.key});

  @override
  State<AbsenKeluarPage> createState() => _AbsenKeluarPageState();
}

class _AbsenKeluarPageState extends State<AbsenKeluarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile
          ? AppBar(
              title: Text(
                context.isIndonesian ? 'Absen Keluar' : "Check Out",
                style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily),
              ),
              backgroundColor: AppColors.bg,
              leading: IconButton(
                icon: const Icon(
                    Icons.arrow_back_ios), // atau CupertinoIcons.back
                color: AppColors.putih,
                onPressed: () => Navigator.of(context).pop(),
              ),
              iconTheme: IconThemeData(
                color: AppColors.putih, // warna ikon back
              ),
            )
          : null,
      body: ListView(children: [
        InputOut(),
      ]),
    );
  }
}

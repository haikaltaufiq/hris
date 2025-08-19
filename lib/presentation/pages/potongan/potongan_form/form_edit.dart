// lib/presentation/pages/potongan/potongan_form/widget/potongan_edit.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/presentation/pages/potongan/potongan_form/widget/potongan_edit.dart';

class PotonganEdit extends StatefulWidget {
  final PotonganGajiModel potongan;

  const PotonganEdit({
    super.key,
    required this.potongan,
  });

  @override
  State<PotonganEdit> createState() => _PotonganEditState();
}

class _PotonganEditState extends State<PotonganEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Edit Potongan',
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
        PotonganEditInput(potongan: widget.potongan),
      ]),
    );
  }
}

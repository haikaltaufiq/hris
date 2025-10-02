// lib/presentation/pages/potongan/potongan_form/widget/potongan_edit.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/features/potongan/potongan_form/widget/potongan_edit.dart';

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
      appBar: context.isMobile
          ? AppBar(
              title: Text(
                context.isIndonesian ? 'Edit Potongan' : 'Deduction Edit',
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
      body: ListView(children: [
        PotonganEditInput(potongan: widget.potongan),
      ]),
    );
  }
}

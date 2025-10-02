import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/features/reminder/widget/reminder_edit.dart';

class ReminderEditForm extends StatelessWidget {
  final ReminderData reminder;

  const ReminderEditForm({
    super.key,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile
          ? AppBar(
              title: Text(
                context.isIndonesian ? 'Edit Pengingat' : 'Edit Reminder',
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
        ReminderEditInput(
          reminder: reminder,
        ),
      ]),
    );
  }
}

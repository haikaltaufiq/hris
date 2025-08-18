import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = "Ya",
  String cancelText = "Batal",
  Color? confirmColor,
}) async {
  final effectiveConfirmColor = confirmColor ?? AppColors.red;
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: AppColors.primary,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColors.putih,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      content: Text(
        content,
        style: GoogleFonts.poppins(
          color: AppColors.putih,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      actions: [
        // Cancel button
        Container(
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.putih.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              cancelText,
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        // Confirm button
        Container(
          height: 40,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: effectiveConfirmColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmText,
              style: GoogleFonts.poppins(
                color: effectiveConfirmColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
  );

  return confirmed ?? false;
}

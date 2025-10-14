import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';

/// Reusable sort/filter dialog
Future<String?> showSortDialog({
  required BuildContext context,
  required String title,
  required List<Map<String, String>> options,
  required String currentValue,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      String selected = currentValue;

      return AlertDialog(
        backgroundColor: AppColors.primary,
        title: Text(
          title,
          style: TextStyle(color: AppColors.putih),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              return RadioListTile<String>(
                value: opt['value']!,
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v!),
                title: Text(
                  opt['label']!,
                  style: TextStyle(color: AppColors.putih),
                ),
                activeColor: AppColors.putih,
              );
            }).toList(),
          ),
        ),
        actions: [
          Row(
            children: [
              // Tombol Batal
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.putih,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 16),
              // Tombol Terapkan
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.putih,
                    minimumSize: const Size.fromHeight(50),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

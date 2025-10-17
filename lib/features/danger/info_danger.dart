import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';

class InfoDanger extends StatelessWidget {
  const InfoDanger({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.5),
        border: Border.all(
          color: AppColors.red.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_rounded,
            color: AppColors.putih,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Data',
                  style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.isIndonesian
                      ? 'Tindakan di bawah ini bersifat permanen dan tidak dapat dibatalkan. Harap berhati-hati sebelum melanjutkan.'
                      : 'Actions below are permanent and cannot be undone. Please proceed with caution.',
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

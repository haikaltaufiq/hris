import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';

class InfoResetPerangkat extends StatelessWidget {
  const InfoResetPerangkat({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.5),
        border: Border.all(color: AppColors.yellow, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.putih,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.isIndonesian ? 'Info Perangkat' : 'Device Info',
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
                      ? 'Menghapus perangkat akan memberikan izin bagi akun untuk melakukan login melalui perangkat lain.'
                      : 'Removing a device will allow the account to log in from another device.',
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

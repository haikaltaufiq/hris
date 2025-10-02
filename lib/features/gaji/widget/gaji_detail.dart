import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:hr/features/gaji/widget/format_currency.dart';
import 'package:hr/features/gaji/widget/potongan.dart';

class GajiDetail extends StatelessWidget {
  final GajiUser gaji;
  const GajiDetail({super.key, required this.gaji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.latar3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.isIndonesian ? "Rincian Gaji" : "Salary Details",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.putih)),
          const SizedBox(height: 12),
          _buildRow(
              context.isIndonesian ? "Gaji Per Hari" : "Daily Salary",
              formatCurrency(gaji.gajiPokok),
              Colors.blue,
              Icons.account_balance_wallet),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.remove_circle_outline,
                  size: 16, color: Colors.red[600]),
              const SizedBox(width: 8),
              Text("Detail Potongan:",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.putih)),
            ],
          ),
          const SizedBox(height: 8),
          if (gaji.potongan.isNotEmpty)
            ...gaji.potongan.map((p) => PotonganItem(potongan: p))
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("Tidak ada potongan",
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey)),
            ),
          _buildRow(
            "Total Potongan",
            "-${formatCurrency(gaji.totalPotongan)}",
            Colors.red,
            Icons.remove_circle,
            isTotal: true,
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text("Gaji Bersih",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[700])),
                  ],
                ),
                Text(formatCurrency(gaji.gajiBersih),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color, IconData icon,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.putih)),
            ],
          ),
          Text(value,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}

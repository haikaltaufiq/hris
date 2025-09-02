import 'package:flutter/material.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/features/gaji/widget/format_currency.dart';

class PotonganItem extends StatelessWidget {
  final PotonganGajiModel potongan;
  const PotonganItem({super.key, required this.potongan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(potongan.namaPotongan,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text("${potongan.nominal}%",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          Text("-${formatCurrency(potongan.nilai ?? 0)}",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700])),
        ],
      ),
    );
  }
}

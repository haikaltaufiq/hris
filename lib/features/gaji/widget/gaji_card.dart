import 'package:flutter/material.dart';
import 'package:hr/core/helpers/cut_string.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:hr/data/services/gaji_service.dart';
import 'package:hr/features/gaji/widget/format_currency.dart';
import 'package:hr/features/gaji/widget/gaji_detail.dart';

class GajiCard extends StatelessWidget {
  final GajiUser gaji;
  final VoidCallback onStatusChanged;

  const GajiCard({
    super.key,
    required this.gaji,
    required this.onStatusChanged,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "sudah dibayar":
        return Colors.green;
      case "belum dibayar":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showStatusDropdown(
      BuildContext context, String currentStatus, int gajiId) {
    final overlay = Navigator.of(context).overlay!.context;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final statusList = ["Sudah Dibayar", "Belum Dibayar"];
    showMenu<String>(
      context: overlay, // pakai overlay context
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + 200,
        offset.dy + size.height + 200,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.secondary,
      elevation: 8,
      items: statusList.map((status) {
        final statusColor = _getStatusColor(status);
        return PopupMenuItem<String>(
          value: status,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).then((selectedStatus) {
      if (selectedStatus != null && selectedStatus != currentStatus) {
        GajiService.updateStatus(gajiId, selectedStatus).then((_) {
          gaji.status = selectedStatus;
          onStatusChanged();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(gaji.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.primary,
        collapsedBackgroundColor: AppColors.primary,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.putih,
                child: Text(
                  gaji.nama.isNotEmpty ? gaji.nama[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.bg,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cutNameToTwoWords(gaji.nama),
                        style: TextStyle(
                          color: AppColors.putih,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      context.isIndonesian
                          ? "Gaji Bersih: ${formatCurrency(gaji.gajiBersih)}"
                          : "Net Salary: ${formatCurrency(gaji.gajiBersih)}",
                      style: TextStyle(
                        color: AppColors.putih,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Custom dropdown status (chip style)
                    Builder(
                      builder: (context) => InkWell(
                        onTap: () {
                          _showStatusDropdown(context, gaji.status, gaji.id);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color, width: 1),
                            color: color.withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                gaji.status,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: color,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        children: [GajiDetail(gaji: gaji)],
      ),
    );
  }
}

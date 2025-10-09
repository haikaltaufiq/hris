import 'package:flutter/material.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:hr/features/gaji/widget/format_currency.dart';
import 'package:hr/features/gaji/widget/gaji_detail.dart';
import 'package:provider/provider.dart';

class GajiTabelWeb extends StatefulWidget {
  final List<GajiUser> gajiList;
  final Function(int gajiId, String newStatus)? onReload;

  const GajiTabelWeb({
    super.key,
    required this.gajiList,
    this.onReload,
  });

  @override
  State<GajiTabelWeb> createState() => _GajiTabelWebState();
}

class _GajiTabelWebState extends State<GajiTabelWeb> {
  void _showDetailDialog(BuildContext context, GajiUser gaji) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.putih,
                        child: Text(
                          gaji.nama.isNotEmpty
                              ? gaji.nama[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.bg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gaji.nama,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.putih,
                            ),
                          ),
                          Text(
                            context.watch<LanguageProvider>().isIndonesian
                                ? "Detail Penggajian"
                                : "Salary Details",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.putih.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.putih),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: GajiDetail(gaji: gaji),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIndo = context.watch<LanguageProvider>().isIndonesian;

    final headers = [
      isIndo ? "Nama" : "Name",
      isIndo ? "Gaji Pokok" : "Base Salary",
      isIndo ? "Total Potongan" : "Total Deductions",
      isIndo ? "Gaji Bersih" : "Net Salary",
      "Status",
    ];

    final rows = widget.gajiList.map((gaji) {
      return [
        gaji.nama,
        formatCurrency(gaji.gajiPokok),
        formatCurrency(gaji.totalPotongan),
        formatCurrency(gaji.gajiBersih),
        gaji.status,
      ];
    }).toList();

    return CustomDataTableWeb(
      headers: headers,
      rows: rows,
      dropdownStatusColumnIndexes: [4],
      statusOptions: ["Belum Dibayar", "Sudah Dibayar"],
      onView: (rowIndex) {
        // Ambil data gaji yang sesuai (reversed list)
        final reversedList = widget.gajiList.reversed.toList();
        final gaji = reversedList[rowIndex];
        _showDetailDialog(context, gaji);
      },
      onStatusChanged: (rowIndex, newStatus) async {
        final reversedList = widget.gajiList.reversed.toList();
        final gaji = reversedList[rowIndex];

        if (widget.onReload != null) {
          await widget.onReload!(gaji.id, newStatus);

          NotificationHelper.showTopNotification(
            context,
            "Status gaji berhasil diubah",
            isSuccess: true,
          );
        }
      },
    );
  }
}

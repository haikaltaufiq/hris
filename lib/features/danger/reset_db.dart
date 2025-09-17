// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/log_service.dart';

class ResetDb extends StatelessWidget {
  const ResetDb({super.key});

  final List<Map<String, String>> resetItems = const [
    {"title": "Gaji", "subtitle": "Reset semua data gaji karyawan."},
    {"title": "Absen", "subtitle": "Reset seluruh catatan absensi."},
    {"title": "Cuti", "subtitle": "Reset data cuti karyawan."},
    {"title": "Lembur", "subtitle": "Reset catatan lembur."},
    {"title": "Tugas", "subtitle": "Reset semua data tugas."},
    {"title": "Log Aktivitas", "subtitle": "Reset riwayat log aktivitas."},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.red, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Danger Zone",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.putih,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(resetItems.length, (index) {
              final item = resetItems[index];
              return Column(
                children: [
                  _dangerRow(context, item),
                  if (index < resetItems.length - 1)
                    Divider(color: AppColors.putih, thickness: 0.5),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _dangerRow(BuildContext context, Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"]!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.putih,
                  ),
                ),
                Text(
                  item["subtitle"]!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.putih.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DangerButton(
            label: "Reset",
            onTap: () => _confirmReset(context, item["title"]!),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, String title) async {
    if (title != "Log Aktivitas") {
      // reset biasa untuk Gaji, Absen, Cuti, dll.
      final confirmed = await showConfirmationDialog(
        context,
        title: "Konfirmasi",
        content: "Yakin Reset $title? Data akan hilang permanen.",
        confirmText: "Reset",
        cancelText: "Batal",
        confirmColor: AppColors.red,
      );

      if (confirmed) {
        debugPrint("$title berhasil direset");
      }
      return;
    }

    // Untuk Log Aktivitas → pilih bulan-tahun dulu
    List<Map<String, dynamic>> months =
        await ActivityLogService.fetchAvailableMonths();

    if (months.isEmpty) {
      NotificationHelper.showTopNotification(
          context, "Data log aktifitas bersih.");

      return;
    }

    // **Panggil showResetLogDialog biar muncul**
    await showResetLogDialog(context: context, months: months);
  }

// Fungsi modal
  Future<void> showResetLogDialog({
    required BuildContext context,
    required List<Map<String, dynamic>> months,
  }) async {
    int? selectedBulan;
    int? selectedTahun;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: context.isMobile ? 0 : 50,
              right: context.isMobile ? 0 : 50,
            ),
            child: Dialog(
              backgroundColor: AppColors.bg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Pilih Bulan Log Aktivitas",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.putih,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<int>(
                        isExpanded: true,
                        value: selectedBulan, // bisa null
                        hint: Text(
                          "Bulan",
                          style: TextStyle(color: AppColors.putih),
                        ),
                        dropdownColor: AppColors.bg,
                        style: TextStyle(color: AppColors.putih),
                        items: months.map((month) {
                          final bulan = month['bulan'] as int;
                          final tahun = month['tahun'] as int;
                          final jumlah = month['jumlah'] as int;
                          return DropdownMenuItem<int>(
                            value: bulan,
                            child: Text("Bulan $bulan - $tahun ($jumlah log)"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedBulan = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (selectedBulan != null)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.secondary),
                                  foregroundColor: AppColors.secondary,
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text("Batal",
                                    style: TextStyle(color: AppColors.putih)),
                              ),
                            ),
                          if (selectedBulan != null) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedBulan != null
                                    ? AppColors.red
                                    : AppColors.secondary,
                                foregroundColor: AppColors.putih,
                              ),
                              onPressed: selectedBulan != null
                                  ? () async {
                                      final monthData = months.firstWhere(
                                          (e) => e['bulan'] == selectedBulan);
                                      selectedTahun = monthData['tahun'];

                                      final confirmed =
                                          await showConfirmationDialog(
                                        context,
                                        title: "Konfirmasi",
                                        content:
                                            "Yakin hapus log bulan $selectedBulan tahun $selectedTahun?",
                                        confirmText: "Reset",
                                        cancelText: "Batal",
                                        confirmColor: AppColors.red,
                                      );

                                      if (confirmed) {
                                        try {
                                          await ActivityLogService.resetByMonth(
                                              selectedBulan!, selectedTahun!);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Log bulan $selectedBulan tahun $selectedTahun berhasil dihapus")),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Gagal menghapus log: $e")),
                                          );
                                        }

                                        Navigator.pop(context); // tutup modal
                                      }
                                    }
                                  : null,
                              child: const Text("Reset Log",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

class DangerButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const DangerButton({super.key, required this.label, required this.onTap});

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isHover ? AppColors.red : Colors.transparent,
            border: Border.all(color: AppColors.red, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: isHover ? Colors.white : AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

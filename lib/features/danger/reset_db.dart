// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/danger_service.dart';

class ResetDb extends StatefulWidget {
  const ResetDb({super.key});

  @override
  State<ResetDb> createState() => _ResetDbState();
}

class _ResetDbState extends State<ResetDb> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> resetItems = context.isIndonesian
        ? [
            {"title": "Gaji", "subtitle": "Reset semua data gaji karyawan."},
            {"title": "Absen", "subtitle": "Reset seluruh catatan absensi."},
            {"title": "Cuti", "subtitle": "Reset data cuti karyawan."},
            {"title": "Lembur", "subtitle": "Reset catatan lembur."},
            {"title": "Tugas", "subtitle": "Reset semua data tugas."},
            {
              "title": "Log Aktivitas",
              "subtitle": "Reset riwayat log aktivitas."
            },
          ]
        : [
            {"title": "Salary", "subtitle": "Reset all salary data."},
            {"title": "Attendance", "subtitle": "Reset all attendance data."},
            {"title": "Leave", "subtitle": "Reset all leave proposal data."},
            {
              "title": "Over Time",
              "subtitle": "Reset all overtime proposal data."
            },
            {"title": "Task", "subtitle": "Reset all task data."},
            {"title": "Log Activity", "subtitle": "Reset all log activity."},
          ];
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
            context.isIndonesian ? "Reset Data" : "Reset Data",
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
    // Map title to jenis
    String? jenis;
    if (title == "Cuti" || title == "Leave") jenis = "cuti";
    if (title == "Gaji" || title == "Salary") jenis = "gaji";
    if (title == "Absen" || title == "Attendance") jenis = "absensi";
    if (title == "Lembur" || title == "Over Time") jenis = "lembur";
    if (title == "Tugas" || title == "Task") jenis = "tugas";
    if (title == "Log Aktivitas" || title == "Log Activity") jenis = "log";

    if (jenis == null) {
      final confirmed = await showTypeConfirmationDialog(
        context,
        title: context.isIndonesian ? "Konfirmasi Reset" : "Confirm Reset",
        content: context.isIndonesian
            ? "Yakin reset $title? Data akan hilang permanen."
            : "Are you sure to reset $title? Data will be permanently deleted.",
        confirmationText: "delete this data",
      );

      if (confirmed) {
        final message = context.isIndonesian
            ? "$title berhasil direset"
            : "$title has been reset successfully";
        NotificationHelper.showTopNotification(context, message,
            isSuccess: true);
      }
      return;
    }

    List<Map<String, dynamic>> months =
        await DangerService.fetchAvailableMonths(jenis: jenis);

    if (months.isEmpty) {
      final message = context.isIndonesian
          ? "Data $title sudah bersih."
          : "$title data is already clean.";
      NotificationHelper.showTopNotification(context, message);
      return;
    }

    await showResetLogDialog(context: context, months: months, jenis: jenis);
  }

  Future<void> showResetLogDialog({
    required BuildContext context,
    required List<Map<String, dynamic>> months,
    required String jenis,
  }) async {
    String? selectedMonth;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // Prepare dropdown items
          final dropdownItems = months.map((month) {
            final bulan = month['bulan'] as int;
            final tahun = month['tahun'] as int;
            final jumlah = month['jumlah'] as int;
            return context.isIndonesian
                ? "Bulan $bulan - $tahun ($jumlah data)"
                : "Month $bulan - $tahun ($jumlah data)";
          }).toList();

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
                constraints: BoxConstraints(
                  maxHeight: 400,
                  maxWidth: context.isMobile ? double.infinity : 600,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.isIndonesian
                            ? "Pilih Bulan ${jenis.toUpperCase()}"
                            : "Choose Month ${jenis.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.putih,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomDropDownField(
                        label: "",
                        hint: context.isIndonesian
                            ? "Pilih Bulan"
                            : "Select Month",
                        items: dropdownItems,
                        value: selectedMonth,
                        onChanged: (val) {
                          setState(() {
                            selectedMonth = val;
                          });
                        },
                        labelStyle: TextStyle(color: AppColors.putih),
                        textStyle: TextStyle(color: AppColors.putih),
                        inputStyle: InputDecoration(
                          filled: true,
                          fillColor: AppColors.bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.putih.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.putih.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        dropdownColor: AppColors.bg,
                        dropdownTextColor: AppColors.putih,
                        dropdownIconColor: AppColors.putih,
                        buttonColor: AppColors.secondary,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (selectedMonth != null)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 58),
                                  side: BorderSide(color: AppColors.secondary),
                                  foregroundColor: AppColors.secondary,
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                    context.isIndonesian ? "Batal" : "Cancel",
                                    style: TextStyle(color: AppColors.putih)),
                              ),
                            ),
                          if (selectedMonth != null) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 58),
                                backgroundColor: selectedMonth != null
                                    ? AppColors.red
                                    : AppColors.secondary,
                                foregroundColor: AppColors.putih,
                              ),
                              onPressed: selectedMonth != null
                                  ? () async {
                                      // Find selected month data
                                      final selectedIndex =
                                          dropdownItems.indexOf(selectedMonth!);
                                      final monthData = months[selectedIndex];
                                      final selectedBulan = monthData['bulan'];
                                      final selectedTahun = monthData['tahun'];

                                      final confirmed =
                                          await showTypeConfirmationDialog(
                                        context,
                                        title: context.isIndonesian
                                            ? "Konfirmasi Reset"
                                            : "Confirm Reset",
                                        content: context.isIndonesian
                                            ? "Yakin reset $jenis bulan $selectedBulan tahun $selectedTahun? Data akan hilang permanen."
                                            : "Are you sure to reset $jenis for month $selectedBulan year $selectedTahun? Data will be permanently deleted.",
                                        confirmationText: "delete this data",
                                      );

                                      if (confirmed) {
                                        try {
                                          await DangerService.resetByMonth(
                                            bulan: selectedBulan,
                                            tahun: selectedTahun,
                                            jenis: jenis,
                                          );
                                          final message = context.isIndonesian
                                              ? "$jenis bulan $selectedBulan tahun $selectedTahun berhasil direset"
                                              : "$jenis for month $selectedBulan year $selectedTahun has been reset successfully";
                                          NotificationHelper
                                              .showTopNotification(
                                                  context, message,
                                                  isSuccess: true);
                                        } catch (e) {
                                          final message = context.isIndonesian
                                              ? "Gagal reset $jenis: $e"
                                              : "Failed to reset $jenis: $e";
                                          NotificationHelper
                                              .showTopNotification(
                                                  context, message,
                                                  isSuccess: false);
                                        }

                                        Navigator.pop(context);
                                      }
                                    }
                                  : null,
                              child: Text("Reset ${jenis.toUpperCase()}",
                                  style: const TextStyle(color: Colors.white)),
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

  /// Show custom confirmation dialog requiring user to type confirmation text
  Future<bool> showTypeConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmationText,
  }) async {
    final textController = TextEditingController();
    bool isMatching = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 24 : 80,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.isMobile ? double.infinity : 500,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: AppColors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.putih,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.putih.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.isIndonesian
                            ? "Ketik '$confirmationText' untuk konfirmasi:"
                            : "Type '$confirmationText' to confirm:",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.putih.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: textController,
                        style: TextStyle(color: AppColors.putih),
                        decoration: InputDecoration(
                          hintText: confirmationText,
                          hintStyle: TextStyle(
                            color: AppColors.putih.withOpacity(0.4),
                          ),
                          filled: true,
                          fillColor: AppColors.bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.putih.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.putih.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.putih,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isMatching = value == confirmationText;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                side: BorderSide(
                                  color: AppColors.secondary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: Text(
                                context.isIndonesian ? "Batal" : "Cancel",
                                style: TextStyle(
                                  color: AppColors.putih,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                backgroundColor: isMatching
                                    ? AppColors.red
                                    : AppColors.secondary,
                                disabledBackgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isMatching
                                  ? () {
                                      Navigator.pop(context, true);
                                    }
                                  : null,
                              child: Text(
                                context.isIndonesian ? "Konfirmasi" : "Confirm",
                                style: TextStyle(
                                  color: AppColors.putih,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return result ?? false;
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
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: isProcessing ? SystemMouseCursors.wait : SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: isProcessing
            ? null
            : () async {
                if (isProcessing) return;

                setState(() => isProcessing = true);

                try {
                  widget.onTap();
                } finally {
                  if (mounted) {
                    setState(() => isProcessing = false);
                  }
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isProcessing
                ? AppColors.red.withOpacity(0.5)
                : (isHover ? AppColors.red : Colors.transparent),
            border: Border.all(color: AppColors.red, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: isProcessing
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
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

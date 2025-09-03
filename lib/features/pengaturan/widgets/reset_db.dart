import 'package:flutter/material.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/core/theme/app_colors.dart';

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

import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/tugas/tugas_form/tugas_edit_form.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/provider/function/tugas_provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TugasTabel extends StatelessWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;
  const TugasTabel({
    super.key,
    required this.tugasList,
    required this.onActionDone,
  });

  final List<String> headers = const [
    "Kepada",
    "Judul",
    "Jam Mulai",
    "Tanggal Mulai",
    "Batas Submit",
    "Lokasi",
    "Note",
    "Status",
  ];

  String parseTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      return DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(time));
    } catch (_) {
      return '';
    }
  }

  String parseDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    } catch (_) {
      return '';
    }
  }

  Future<void> _editTugas(BuildContext context, int row) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TugasEditForm(
          tugas: tugasList[row],
        ),
      ),
    );
    onActionDone?.call();
  }

  Future<void> _deleteTugas(BuildContext context, TugasModel tugas) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Hapus",
      content: "Apakah Anda yakin ingin menghapus tugas ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message =
          await context.read<TugasProvider>().deleteTugas(tugas.id, "");
      NotificationHelper.showTopNotification(
        context,
        message ?? 'Gagal menghapus tugas',
        isSuccess: message != null,
      );
    }
    onActionDone?.call();
  }

  void _showDetailDialog(BuildContext context, TugasModel tugas) {
    Color statusColor;
    switch (tugas.status.toLowerCase()) {
      case 'selesai':
        statusColor = Colors.green;
        break;
      case 'proses':
        statusColor = Colors.orange;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Detail Tugas',
          style: GoogleFonts.poppins(
            color: AppColors.putih,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailItem(label: 'Kepada', value: tugas.user?.nama ?? '-'),
            SizedBox(height: 5),
            DetailItem(label: 'Judul', value: tugas.namaTugas),
            SizedBox(height: 5),
            DetailItem(label: 'Jam Mulai', value: parseTime(tugas.jamMulai)),
            SizedBox(height: 5),
            DetailItem(
                label: 'Tanggal Mulai', value: parseDate(tugas.tanggalMulai)),
            SizedBox(height: 5),
            DetailItem(
                label: 'Batas Submit', value: parseDate(tugas.tanggalSelesai)),
            SizedBox(height: 5),
            DetailItem(label: 'Lokasi', value: tugas.lokasi),
            SizedBox(height: 5),
            DetailItem(label: 'Note', value: tugas.note),
            SizedBox(height: 5),
            DetailItem(
                label: 'Status', value: tugas.status, color: statusColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tugasList.isEmpty) {
      return const Center(
        child: Text('Belum ada tugas', style: TextStyle(color: Colors.white)),
      );
    }

    final rows = tugasList.map((tugas) {
      return [
        tugas.user?.nama ?? '-',
        tugas.shortTugas,
        parseTime(tugas.jamMulai),
        parseDate(tugas.tanggalMulai),
        parseDate(tugas.tanggalSelesai),
        tugas.lokasi,
        tugas.note,
        tugas.status,
      ];
    }).toList();

    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: const [7],
      onView: (row) => _showDetailDialog(context, tugasList[row]),
      onEdit: (row) => _editTugas(context, row),
      onDelete: (row) => _deleteTugas(context, tugasList[row]),
    );
  }
}

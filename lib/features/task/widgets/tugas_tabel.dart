import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/tugas_form/tugas_edit_form.dart';
import 'package:hr/features/task/widgets/video.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/helpers/notification_helper.dart';
import '../../../core/theme/app_colors.dart';

class TugasTabel extends StatefulWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;
  const TugasTabel({
    super.key,
    required this.tugasList,
    required this.onActionDone,
  });

  @override
  State<TugasTabel> createState() => _TugasTabelState();
}

class _TugasTabelState extends State<TugasTabel> {
  final List<String> headers = const [
    "Kepada",
    "Judul",
    "Jam Mulai",
    "Tanggal Mulai",
    "Batas Submit",
    "Lokasi",
    "Note",
    "Status",
    "Lampiran"
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
          tugas: widget.tugasList[row],
        ),
      ),
    );
    widget.onActionDone?.call();
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
    widget.onActionDone?.call();
  }

  // lampiran tipe file
  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak bisa membuka $url';
    }
  }


  // lampiran
  void _showLampiranDialog(BuildContext context, TugasModel tugas) {
    if (tugas.lampiran == null) {
      NotificationHelper.showTopNotification(
        context,
        "Tidak ada lampiran untuk tugas ini",
        isSuccess: false,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Lampiran Tugas',
          style: GoogleFonts.poppins(
              color: AppColors.putih, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          height: 300,
          child: buildLampiranWidget(tugas.lampiran!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(color: AppColors.putih, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLampiranWidget(String url) {
    final ext = url.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi', '3gp'].contains(ext)) {
      return VideoPlayerWidget(videoUrl: url);
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return Image.network(url, fit: BoxFit.contain);
    } else if (ext == 'pdf') {
      return Center(child: Text('PDF Viewer bisa ditambahkan di sini'));
    } else if (['mp3', 'wav', 'm4a'].contains(ext)) {
      return Center(child: Text('Audio Player bisa ditambahkan di sini'));
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: () => _downloadFile(url),
          child: const Text('Download Lampiran'),
        ),
      );
    }
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
    if (widget.tugasList.isEmpty) {
      return const Center(
        child: Text('Belum ada tugas', style: TextStyle(color: Colors.white)),
      );
    }

    widget.tugasList.map((tugas) {
      return [
        tugas.user?.nama ?? '-',
        tugas.shortTugas,
        parseTime(tugas.jamMulai),
        parseDate(tugas.tanggalMulai),
        parseDate(tugas.tanggalSelesai),
        tugas.lokasi,
        tugas.note,
        tugas.status,
        tugas.lampiran != null ? "Lihat Lampiran" : "-"
      ];
    }).toList();
    return Consumer<TugasProvider>(
      builder: (context, tugasProvider, _) {
        final tugasList = tugasProvider.tugasList; // ambil dari provider
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
            tugas.lampiran != null ? "Lihat Lampiran" : "-"
          ];
        }).toList();

        return CustomDataTableWidget(
          headers: headers,
          rows: rows,
          dropdownStatusColumnIndexes: [7],
          statusOptions: ['Selesai', 'Menunggu Admin', 'Proses'],
          onStatusChanged: (rowIndex, newStatus) async {
            final tugas = tugasList[rowIndex];
            final message = await context.read<TugasProvider>()
                .updateTugasStatus(tugas.id, newStatus);

            NotificationHelper.showTopNotification(
              context,
              message ?? 'Gagal update status',
              isSuccess: message != null,
            );
          },
          onView: (row) => _showDetailDialog(context, tugasList[row]),
          onEdit: (row) => _editTugas(context, row),
          onDelete: (row) => _deleteTugas(context, tugasList[row]),
          onTapLampiran: (row) => _showLampiranDialog(context, tugasList[row]),
          onCellTap: (row, col) => print('Cell tapped: Row $row, Col $col'),
        );
      },
    );
  }
}

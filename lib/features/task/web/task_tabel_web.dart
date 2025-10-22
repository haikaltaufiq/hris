import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/widgets/video.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/helpers/notification_helper.dart';
import '../../../core/theme/app_colors.dart';

class TugasTabelWeb extends StatefulWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;
  const TugasTabelWeb({
    super.key,
    required this.tugasList,
    required this.onActionDone,
  });

  @override
  State<TugasTabelWeb> createState() => _TugasTabelWebState();
}

class _TugasTabelWebState extends State<TugasTabelWeb> {
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
      final parsed = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return date; // fallback kalau parsing gagal
    }
  }

  Future<void> _editTugas(BuildContext context, int row) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.taskEdit,
      arguments: widget.tugasList[row], // passing data tugas
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
      final message = await context.read<TugasProvider>().deleteTugas(tugas.id);
      NotificationHelper.showTopNotification(
        context,
        message ?? 'Gagal menghapus tugas',
        isSuccess: message != null,
      );
    }
    widget.onActionDone?.call();
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
          onPressed: () {},
          child: Text('Download Lampiran'),
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
            DetailItem(
              label: 'Kepada',
              value: tugas.user?.nama ?? '-',
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Judul',
              value: tugas.namaTugas,
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Tanggal Mulai',
              value: parseDate(tugas.tanggalPenugasan),
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Batas Submit',
              value: parseDate(tugas.batasPenugasan),
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Note',
              value: tugas.note ?? '-',
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Status',
              value: tugas.status,
              color: statusColor,
            ),
            SizedBox(height: 5),
            DetailItem(
              label: 'Ketepatan',
              value: tugas.displayTerlambat,
            ),
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

  void _openMap(String latlongStr) {
    try {
      final parts = latlongStr.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      Navigator.pushNamed(
        context,
        AppRoutes.mapPage,
        arguments: LatLng(lat, lng),
      );
    } catch (_) {
      NotificationHelper.showTopNotification(
        context,
        "Format lokasi tidak valid",
        isSuccess: false,
      );
    }
  }

  String _hitungSisaWaktu(String? batas) {
    if (batas == null) return "-";
    try {
      final deadline = DateTime.parse(batas);
      final now = DateTime.now();
      final diff = deadline.difference(now);

      if (diff.isNegative) {
        return "Lewat ${diff.inMinutes.abs()} menit";
      } else {
        final jam = diff.inHours;
        final menit = diff.inMinutes.remainder(60);
        return "$jam jam $menit menit lagi";
      }
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> headers = context.isIndonesian
        ? [
            "Kepada",
            "Judul",
            "Tgl Mulai",
            "Batas Submit",
            "Radius Lokasi",
            "Lokasi Tugas",
            "Lokasi Lampiran",
            "Status",
            "Catatan",
            "Lampiran",
            "Waktu Upload",       
            "Keterlambatan",
            "Sisa Waktu",      
            "Ketepatan"
          ]
        : [
            "To",
            "Title",
            "Start Date",
            "Deadline",
            "Location Radius",
            "Task Location",
            "Attachment Location",
            "Status",
            "Note",
            "Attachment",
            "Upload Time",         
            "Delay",
            "Remaining Time",             
            "Punctuality"
          ];
    final rows = widget.tugasList.map((tugas) {
      return [
        tugas.displayUser,
        tugas.shortTugas,
        parseDate(tugas.tanggalPenugasan),
        parseDate(tugas.batasPenugasan),
        "${tugas.radius} M",
        tugas.displayLokasiTugas != null && tugas.displayLokasiTugas != "-"
            ? "See Location"
            : '-',
        tugas.displayLokasiLampiran != null &&
                tugas.displayLokasiLampiran != "-"
            ? "See Location"
            : '-',
        tugas.status,
        tugas.displayNote,
        tugas.displayLampiran,
        tugas.waktuUpload == null
          ? _hitungSisaWaktu(tugas.batasPenugasan)
          : "-", // kalau sudah upload, gak perlu tampilkan countdown lagi
        tugas.menitTerlambat != null
            ? "${tugas.menitTerlambat} menit"
            : (tugas.waktuUpload != null ? "Tepat waktu" : "-"),
        tugas.lampiran != null ? tugas.displayTerlambat : '-',
      ];
    }).toList();

    return CustomDataTableWeb(
      headers: headers,
      rows: rows,
      dropdownStatusColumnIndexes: [7],
      statusOptions: ['Selesai', 'Menunggu Admin', 'Proses'],
      onStatusChanged: (rowIndex, newStatus) async {
        final tugas = widget.tugasList[rowIndex];
        final message = await context
            .read<TugasProvider>()
            .updateTugasStatus(tugas.id, newStatus);

        NotificationHelper.showTopNotification(
          context,
          message ?? 'Gagal update status',
          isSuccess: message != null,
        );
      },
      onView: (actualRowIndex) =>
          _showDetailDialog(context, widget.tugasList[actualRowIndex]),
      onEdit: (actualRowIndex) => _editTugas(context, actualRowIndex),
      onDelete: (actualRowIndex) =>
          _deleteTugas(context, widget.tugasList[actualRowIndex]),
      onTapLampiran: (actualRowIndex) =>
          _showLampiranDialog(context, widget.tugasList[actualRowIndex]),
      onCellTap: (paginatedRowIndex, colIndex, actualRowIndex) {
        final tugas = widget.tugasList[actualRowIndex];
        if (colIndex == 5 && tugas.tugasLat != null && tugas.tugasLng != null) {
          _openMap("${tugas.tugasLat},${tugas.tugasLng}");
        }
        if (colIndex == 6 &&
            tugas.lampiranLat != null &&
            tugas.lampiranLng != null) {
          _openMap("${tugas.lampiranLat},${tugas.lampiranLng}");
        }
      },
    );
  }
}

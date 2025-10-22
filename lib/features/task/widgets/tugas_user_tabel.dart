import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/task/tugas_form/form_user_edit.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TugasUserTabel extends StatelessWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;

  const TugasUserTabel({
    super.key,
    required this.tugasList,
    this.onActionDone,
  });

  // Format HH:mm
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

  // Edit tugas
  Future<void> _editTugas(BuildContext context, int row) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormUserEdit(
          tugas: tugasList[row],
        ),
      ),
    );

    onActionDone?.call();
  }

  // Detail dialog
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
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return DetailItem(label: 'Kepada', value: tugas.displayUser);
                case 1:
                  return DetailItem(label: 'Judul', value: tugas.namaTugas);
                case 2:
                  return DetailItem(
                      label: 'Tanggal Mulai',
                      value: parseDate(tugas.tanggalPenugasan));
                case 3:
                  return DetailItem(
                      label: 'Batas Submit',
                      value: parseDate(tugas.batasPenugasan));
                case 4:
                  return DetailItem(
                      label: 'Lokasi', value: tugas.displayLokasiTugas);
                case 5:
                  return DetailItem(label: 'Note', value: tugas.displayNote);
                case 6:
                  return DetailItem(
                      label: 'Status', value: tugas.status, color: statusColor);
                default:
                  return const SizedBox();
              }
            },
          ),
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

    if (tugasList.isEmpty) {
      return const Center(
        child: Text('Belum ada tugas', style: TextStyle(color: Colors.white)),
      );
    }

    // Build rows
    final rows = tugasList.map((tugas) {
      // final hasLampiran = (tugas.lampiran ?? '').toString().trim().isNotEmpty;
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
        tugas.displayWaktuUpload,
        tugas.menitTerlambat != null
            ? "${tugas.menitTerlambat} menit"
            : (tugas.waktuUpload != null ? "Tepat waktu" : "-"),
        tugas.waktuUpload == null
            ? _hitungSisaWaktu(tugas.batasPenugasan)
            : "-", // kalau sudah upload, gak perlu tampilkan countdown lagi
        tugas.lampiran != null ? tugas.displayTerlambat : '-',
      ];
    }).toList();

    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: const [7], // status di kolom ke-6
      onCellTap: (row, col) {
        if (col == 9) {
          // Lampiran di kolom terakhir
          _editTugas(context, row);
        }
      },
      onView: (row) => _showDetailDialog(context, tugasList[row]),
      onEdit: (row) => _editTugas(context, row),
      onTapLampiran: (row) => _editTugas(context, tugasList[row] as int),
    );
  }
}

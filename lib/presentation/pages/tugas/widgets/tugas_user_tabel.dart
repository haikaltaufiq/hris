import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/tugas/tugas_form/form_user_edit.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TugasUserTabel extends StatelessWidget {
  final List<TugasModel> tugasList;
  final VoidCallback? onActionDone;
  const TugasUserTabel({
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
    "Lampiran",
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
        builder: (_) => FormUserEdit(
          tugas: tugasList[row],
        ),
      ),
    );
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
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6, // dialog lebih lebar
          height:
              MediaQuery.of(context).size.height * 0.5, // tinggi lebih besar
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 8,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12), // jarak antar item
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return DetailItem(
                      label: 'Kepada', value: tugas.user?.nama ?? '-');
                case 1:
                  return DetailItem(label: 'Judul', value: tugas.namaTugas);
                case 2:
                  return DetailItem(
                      label: 'Jam Mulai', value: parseTime(tugas.jamMulai));
                case 3:
                  return DetailItem(
                      label: 'Tanggal Mulai',
                      value: parseDate(tugas.tanggalMulai));
                case 4:
                  return DetailItem(
                      label: 'Batas Submit',
                      value: parseDate(tugas.tanggalSelesai));
                case 5:
                  return DetailItem(label: 'Lokasi', value: tugas.lokasi);
                case 6:
                  return DetailItem(label: 'Note', value: tugas.note);
                case 7:
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
        "Upload Tugas ",
      ];
    }).toList();

    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: const [7],
      onView: (row) => _showDetailDialog(context, tugasList[row]),
      onEdit: (row) => _editTugas(context, row), 
      onTapLampiran: (row) {  },
    );
  }
}

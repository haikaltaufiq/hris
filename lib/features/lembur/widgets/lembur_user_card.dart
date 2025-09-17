import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/helpers/format_time.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/lembur_model.dart';

class UserLemburTabel extends StatelessWidget {
  final void Function(LemburModel lembur) onDelete;
  final List<LemburModel> lemburList;

  const UserLemburTabel({
    super.key,
    required this.lemburList,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDataTableWidget(
      headers: [
        'Nama',
        'Tanggal Lembur',
        'Jam Mulai',
        'Jam Selesai',
        'Alasan',
        'Status',
        'Keterangan',
      ],
      rows: lemburList.map((c) {
        final status = c.status.toString().toLowerCase();

        // default value biar tetep length sama
        String kolom7 = c.keteranganStatus;
        String kolom8 = '-';

        // kalau status ditolak → kolom 7 kosong, kolom 8 isi keterangan_status
        if (status == 'ditolak') {
          kolom7 = 'Gaboleh Lembur jir';
          kolom8 = c.keteranganStatus;
        }

        return [
          c.user['nama']?.toString() ?? '',
          DateHelper.format(c.tanggal).toString(),
          FormatTime().formatTime(c.jamMulai).toString(),
          FormatTime().formatTime(c.jamSelesai).toString(),
          c.shortDeskripsi.toString(),
          c.status.toString(),
          kolom7,
          kolom8,
        ];
      }).toList(),
      statusColumnIndexes: [5],
      onCellTap: (row, col) {},
      onView: (row) {
        final c = lemburList[row];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Detail Lembur',
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailItem(label: 'Nama', value: c.user['nama']),
                DetailItem(
                    label: 'Status', value: c.status, color: c.statusColor),
                DetailItem(
                    label: 'Tanggal Lembur',
                    value: DateHelper.format(c.tanggal)),
                DetailItem(
                    label: 'Jam Mulai',
                    value: FormatTime().formatTime(c.jamMulai)),
                DetailItem(
                    label: 'Jam Selesai',
                    value: FormatTime().formatTime(c.jamSelesai)),
                DetailItem(label: 'Deskripsi', value: c.deskripsi),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup',
                    style: GoogleFonts.poppins(
                      color: AppColors.putih,
                      fontSize: 16,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}

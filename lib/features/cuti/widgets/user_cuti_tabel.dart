import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/cuti_model.dart';

class UserCutiTabel extends StatelessWidget {
  final void Function(CutiModel cuti) onDelete;
  final List<CutiModel> cutiList;

  const UserCutiTabel({
    super.key,
    required this.cutiList,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDataTableWidget(
      headers: context.isIndonesian
          ? [
              'Nama',
              'Tipe Cuti',
              'Mulai Cuti',
              'Selesai Cuti',
              'Alasan',
              'Status',
              'Keterangan',
            ]
          : [
              'Name',
              'Leave Type',
              'Start Leave',
              'End Leave',
              'Reason',
              'Status',
              'Description',
            ],
      rows: cutiList.map((c) {
        final status = c.status.toString().toLowerCase();

        // default value biar tetep length sama
        String kolom7 = c.keterangan_status;
        String kolom8 = '-';

        // kalau status ditolak → kolom 7 kosong, kolom 8 isi keterangan_status
        if (status.toLowerCase() == 'ditolak') {
          kolom7 = c.catatan_penolakan;
          kolom8 = c.keterangan_status;
        }

        return [
          c.user['nama']?.toString() ?? '',
          c.tipe_cuti.toString(),
          DateHelper.format(c.tanggal_mulai).toString(),
          DateHelper.format(c.tanggal_selesai).toString(),
          c.shortAlasan.toString(),
          c.status.toString(),
          kolom7,
          kolom8,
        ];
      }).toList(),
      statusColumnIndexes: [5],
      onCellTap: (row, col) {},
      onView: (row) {
        final c = cutiList[row];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              context.isIndonesian ? 'Detail Cuti' : "Leave Detail",
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
                DetailItem(label: 'Tipe Cuti', value: c.tipe_cuti),
                DetailItem(
                    label: 'Tanggal Mulai',
                    value: DateHelper.format(c.tanggal_mulai)),
                DetailItem(
                    label: 'Tanggal Selesai',
                    value: DateHelper.format(c.tanggal_selesai)),
                DetailItem(
                    label: 'Alasan',
                    value: c.status.toLowerCase() == 'ditolak'
                        ? c.catatan_penolakan
                        : c.keterangan_status),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.isIndonesian ? 'Tutup' : 'Close',
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

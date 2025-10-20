import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/update_status_dialog.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/cuti_model.dart';

class WebTabelCuti extends StatelessWidget {
  // final void Function(CutiModel cuti) onDelete;
  final List<CutiModel> cutiList;
  final void Function(CutiModel cuti) onApprove;
  final void Function(CutiModel cuti) onDecline;

  const WebTabelCuti({
    super.key,
    required this.cutiList,
    // required this.onDelete,
    required this.onApprove,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDataTableWeb(
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
        return [
          c.user['nama']?.toString() ?? '',
          c.tipe_cuti.toString(),
          DateHelper.format(c.tanggal_mulai).toString(),
          DateHelper.format(c.tanggal_selesai).toString(),
          c.shortAlasan.toString(),
          c.status.toString(),
          c.keterangan_status,
        ];
      }).toList(),
      statusColumnIndexes: [5],
      onCellTap: (paginatedRowIndex, colIndex, actualRowIndex) {},
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
                DetailItem(
                    label: context.isIndonesian ? 'Nama' : 'Name',
                    value: c.user['nama']),
                DetailItem(
                    label: 'Status', value: c.status, color: c.statusColor),
                DetailItem(label: 'Tipe Cuti', value: c.tipe_cuti),
                DetailItem(
                    label:
                        context.isIndonesian ? 'Tanggal Mulai' : "Start Date",
                    value: DateHelper.format(c.tanggal_mulai)),
                DetailItem(
                    label:
                        context.isIndonesian ? 'Tanggal Selesai' : 'End Date',
                    value: DateHelper.format(c.tanggal_selesai)),
                DetailItem(
                    label: context.isIndonesian ? 'Alasan' : 'Reason',
                    value: c.alasan),
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
      // onDelete: (row) {
      //   final c = cutiList[row];
      //   onDelete(c);
      // },
      onEdit: (cutiList.any((c) => c.isApproved || c.isDitolak))
          ? null
          : (row) {
              final c = cutiList[row];
              showDialog(
                context: context,
                builder: (_) => UpdateStatusDialog(
                  onApprove: () async {
                    onApprove(c);
                    return;
                  },
                  onDecline: () async {
                    onDecline(c);
                    return;
                  },
                ),
              );
            },
    );
  }
}

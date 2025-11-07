import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/update_status_dialog.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/format_time.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/lembur_model.dart';

class WebTabelLembur extends StatelessWidget {
  // final void Function(LemburModel lembur) onDelete;
  final List<LemburModel> lemburList;
  final void Function(LemburModel lembur) onApprove;
  final void Function(LemburModel lembur) onDecline;

  const WebTabelLembur({
    super.key,
    required this.lemburList,
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
              'Tanggal Lembur',
              'Jam Mulai',
              'Jam Selesai',
              'Alasan',
              'Status',
              'Keterangan',
            ]
          : [
              'Name',
              'Date',
              'Start Time',
              'End Time',
              'Reason',
              'Status',
              'Description',
            ],
      rows: lemburList.map((c) {
        final keterangan =
            c.isDitolak ? c.catatan_penolakan : c.keteranganStatus;
        return [
          c.user['nama']?.toString() ?? '',
          DateHelper.format(c.tanggal).toString(),
          FormatTime().formatTime(c.jamMulai).toString(),
          FormatTime().formatTime(c.jamSelesai).toString(),
          c.shortDeskripsi.toString(),
          c.status.toString(),
          keterangan
        ];
      }).toList(),
      statusColumnIndexes: [5],
      onCellTap: (paginatedRowIndex, colIndex, actualRowIndex) {},
      onView: (actualRowIndex) {
        final c = lemburList[actualRowIndex];
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
                    label: 'Tanggal Lembur',
                    value: DateHelper.format(c.tanggal)),
                DetailItem(
                    label: 'Jam Mulai',
                    value: FormatTime().formatTime(c.jamMulai)),
                DetailItem(
                    label: 'Jam Selesai',
                    value: FormatTime().formatTime(c.jamSelesai)),
                DetailItem(label: 'Alasan', value: c.deskripsi),
                DetailItem(
                    label: 'Status', value: c.status, color: c.statusColor),
                DetailItem(
                    label: 'Deskripsi',
                    value:
                        c.isDitolak ? c.catatan_penolakan : c.keteranganStatus),
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
      // onDelete: (row) {
      //   final c = lemburList[row];
      //   onDelete(c);
      // },

      onEdit: (actualRowIndex) {
        final c = lemburList[actualRowIndex];
        if (c.isApproved || c.isDitolak) {
          NotificationHelper.showTopNotification(
              context,
              context.isIndonesian
                  ? 'Status ajuan lembur sudah final, tidak dapat diubah kembali.'
                  : 'Overtime request status is final, cannot be changed again.',
              isSuccess: false);
          return;
        }
        showDialog(
          context: context,
          builder: (_) => UpdateStatusDialog(
            onApprove: () async {
              onApprove(c);
            },
            onDecline: () async {
              onDecline(c);
            },
          ),
        );
      },
    );
  }
}

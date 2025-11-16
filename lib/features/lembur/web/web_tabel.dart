import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
// import 'package:hr/components/dialog/update_status_dialog.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/feature_guard.dart';
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
    final bool hasAccess = FeatureAccess.has("approve_lembur");
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
      dropdownStatusColumnIndexes: hasAccess ? [5] : null,
      statusColumnIndexes: hasAccess ? null : [5],
      statusOptions: hasAccess
          ? [
              context.isIndonesian ? "Disetujui" : "Approved",
              context.isIndonesian ? "Ditolak" : "Declined"
            ]
          : null,
      onStatusChanged: hasAccess
          ? (actualRowIndex, newStatus) {
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
              if (newStatus.toLowerCase() ==
                  (context.isIndonesian ? 'disetujui' : 'approved')
                      .toLowerCase()) {
                onApprove(c);
              } else if (newStatus.toLowerCase() ==
                  (context.isIndonesian ? 'ditolak' : 'declined')
                      .toLowerCase()) {
                onDecline(c);
              }
            }
          : null,
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
                DetailItem(
                    label: context.isIndonesian ? 'Nama' : 'Name',
                    value: c.user['nama']),
                DetailItem(
                    label: context.isIndonesian
                        ? 'Tanggal Lembur'
                        : 'Overtime Date',
                    value: DateHelper.format(c.tanggal)),
                DetailItem(
                    label: context.isIndonesian ? 'Jam Mulai' : 'Start Time',
                    value: FormatTime().formatTime(c.jamMulai)),
                DetailItem(
                    label: context.isIndonesian ? 'Jam Selesai' : 'End Time',
                    value: FormatTime().formatTime(c.jamSelesai)),
                DetailItem(
                    label: context.isIndonesian ? 'Alasan' : 'Reason',
                    value: c.deskripsi),
                DetailItem(
                    label: context.isIndonesian ? 'Status' : 'Status',
                    value: c.status,
                    color: c.statusColor),
                DetailItem(
                    label: context.isIndonesian ? 'Deskripsi' : 'Description',
                    value:
                        c.isDitolak ? c.catatan_penolakan : c.keteranganStatus),
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
      //   final c = lemburList[row];
      //   onDelete(c);
      // },

      // onEdit: (actualRowIndex) {
      //   final c = lemburList[actualRowIndex];
      //   if (c.isApproved || c.isDitolak) {
      //     NotificationHelper.showTopNotification(
      //         context,
      //         context.isIndonesian
      //             ? 'Status ajuan lembur sudah final, tidak dapat diubah kembali.'
      //             : 'Overtime request status is final, cannot be changed again.',
      //         isSuccess: false);
      //     return;
      //   }
      //   showDialog(
      //     context: context,
      //     builder: (_) => UpdateStatusDialog(
      //       onApprove: () async {
      //         onApprove(c);
      //       },
      //       onDecline: () async {
      //         onDecline(c);
      //       },
      //     ),
      //   );
      // },
    );
  }
}

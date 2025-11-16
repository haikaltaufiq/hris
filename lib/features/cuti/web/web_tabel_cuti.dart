import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
// import 'package:hr/components/dialog/update_status_dialog.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/helpers/notification_helper.dart';
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
    final bool hasAccess = FeatureAccess.has("approve_cuti");
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
        // kalau status ditolak → kolom 7 kosong, kolom 8 isi keterangan_status
        final keterangan =
            c.isDitolak ? c.catatan_penolakan : c.keterangan_status;
        return [
          c.user['nama']?.toString() ?? '',
          c.tipe_cuti.toString(),
          DateHelper.format(c.tanggal_mulai).toString(),
          DateHelper.format(c.tanggal_selesai).toString(),
          c.shortAlasan.toString(),
          c.status.toString(),
          keterangan,
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
          ? (rowIndex, newStatus) {
              final c = cutiList[rowIndex];
              if (c.isApproved || c.isDitolak) {
                NotificationHelper.showTopNotification(
                  context,
                  context.isIndonesian
                      ? 'Status ajuan cuti sudah final, tidak dapat diubah kembali.'
                      : 'Leave request status is final, cannot be changed again.',
                  isSuccess: false,
                );
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
                    label: context.isIndonesian ? 'Tipe Cuti' : 'Leave Type',
                    value: c.tipe_cuti),
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
                DetailItem(
                    label: 'Status', value: c.status, color: c.statusColor),
                DetailItem(
                    label: context.isIndonesian ? 'Deskripsi' : 'Description',
                    value: c.isDitolak
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
      // onDelete: (row) {
      //   final c = cutiList[row];
      //   onDelete(c);
      // },
      // onEdit: (row) {
      //   final c = cutiList[row];
      //   if (c.isApproved || c.isDitolak) {
      //     NotificationHelper.showTopNotification(
      //       context,
      //       context.isIndonesian
      //           ? 'Status ajuan cuti sudah final, tidak dapat diubah kembali.'
      //           : 'Leave request status is final, cannot be changed again.',
      //       isSuccess: false,
      //     );
      //     return;
      //   }
      //   showDialog(
      //     context: context,
      //     builder: (_) => UpdateStatusDialog(
      //       onApprove: () async {
      //         onApprove(c);
      //         return;
      //       },
      //       onDecline: () async {
      //         onDecline(c);
      //         return;
      //       },
      //     ),
      //   );
      // },
    );
  }
}

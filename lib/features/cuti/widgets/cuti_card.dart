import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/button/action_button.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/update_status_dialog.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
// import 'package:hris_project/features/dashboard/widget/dashboard_menu.dart';
import 'package:provider/provider.dart';

class CutiCard extends StatelessWidget {
  final CutiModel cuti;
  final Future<void> Function() onApprove;
  final Future<void> Function() onDecline;
  final VoidCallback? onDelete;

  const CutiCard({
    super.key,
    required this.cuti,
    required this.onApprove,
    required this.onDecline,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // final role = context.watch<UserProvider>().roleName;
    return ChangeNotifierProvider(
      create: (_) => CutiProvider(),
      builder: (context, _) {
        context.watch<CutiProvider>();

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        title: Text(
                            context.isIndonesian
                                ? 'Detail Cuti'
                                : "Leave Detail",
                            style: GoogleFonts.poppins(
                                color: AppColors.putih,
                                fontWeight: FontWeight.w600)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DetailItem(
                                label: context.isIndonesian ? 'Nama' : 'Name',
                                value: cuti.user['nama']),
                            DetailItem(
                                label: context.isIndonesian
                                    ? 'Tipe Cuti'
                                    : "Leave Type",
                                value: cuti.tipe_cuti),
                            DetailItem(
                                label: context.isIndonesian
                                    ? 'Tanggal Mulai'
                                    : "Start Date",
                                value: DateHelper.format(cuti.tanggal_mulai)),
                            DetailItem(
                                label: context.isIndonesian
                                    ? 'Tanggal Selesai'
                                    : "End Date",
                                value: DateHelper.format(cuti.tanggal_selesai)),
                            DetailItem(
                                label:
                                    context.isIndonesian ? 'Alasan' : 'Reason',
                                value: cuti.alasan),
                            DetailItem(
                                label: 'Status',
                                value: cuti.status,
                                color: cuti.statusColor),
                            DetailItem(
                                label: context.isIndonesian
                                    ? 'Keterangan'
                                    : "Description",
                                value: cuti.status.toLowerCase() == 'ditolak'
                                    ? cuti.catatan_penolakan
                                    : cuti.keterangan_status),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child:
                                Text(context.isIndonesian ? 'Tutup' : "Close",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.putih,
                                      fontSize: 16,
                                    )),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cuti.user['nama'],
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: AppColors.putih,
                                  fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: cuti.statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cuti.status,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  color: cuti.statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${DateHelper.format(cuti.tanggal_mulai)} - ${DateHelper.format(cuti.tanggal_selesai)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.putih,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(cuti.tipe_cuti,
                          style: GoogleFonts.poppins(
                            color: AppColors.putih,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )),
                      const SizedBox(height: 8),
                      Text(cuti.shortAlasan,
                          style: GoogleFonts.poppins(
                            color: AppColors.putih,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )),
                      const SizedBox(height: 8),
                      Text(
                          cuti.status.toLowerCase() == 'ditolak'
                              ? cuti.shortCatatanPenolakan
                              : cuti.keterangan_status,
                          style: GoogleFonts.poppins(
                            color: AppColors.putih,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cuti.isPending) ...[
                      // Semua role boleh Approve & Decline
                      ActionButton(
                        label: context.isIndonesian ? 'Tolak' : 'Decline',
                        color: AppColors.red,
                        onTap: () => onDecline(),
                      ),
                      ActionButton(
                        label: context.isIndonesian ? 'Setujui' : 'Approve',
                        color: AppColors.green,
                        onTap: () => onApprove(),
                      ),
                    ] else if (cuti.isProses) ...[
                      // Selain Admin Office → tetep Approve & Decline
                      FeatureGuard(
                        requiredFeature: 'approve_lembur_step2',
                        child: ActionButton(
                          label: context.isIndonesian ? "Tolak" : 'Decline',
                          color: AppColors.red,
                          onTap: () => onDecline(),
                        ),
                      ),
                      FeatureGuard(
                        requiredFeature: 'approve_lembur_step2',
                        child: ActionButton(
                          label: context.isIndonesian ? "Setujui" : 'Approve',
                          color: AppColors.green,
                          onTap: () => onApprove(),
                        ),
                      ),
                      FeatureGuard(
                        requiredFeature: 'approve_lembur_step1',
                        child: ActionButton(
                          label: 'Edit',
                          color: AppColors.yellow,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => UpdateStatusDialog(
                                onApprove: onApprove,
                                onDecline: onDecline,
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      // Admin Office pas Proses, atau status lain → Edit & Delete
                      // ActionButton(
                      //   label: 'Delete',
                      //   color: AppColors.red,
                      //   onTap: () => onDelete(),
                      // ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

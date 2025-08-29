import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/button/action_button.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/update_status_dialog.dart';
import 'package:hr/core/helpers/format_time.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/lembur_model.dart';
import 'package:hr/features/lembur/lembur_viewmodel/lembur_provider.dart';
import 'package:provider/provider.dart';

class LemburCard extends StatelessWidget {
  final LemburModel lembur;
  final Future<void> Function() onApprove;
  final Future<void> Function() onDecline;
  final VoidCallback onDelete;

  const LemburCard({
    super.key,
    required this.lembur,
    required this.onApprove,
    required this.onDecline,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // final role = context.watch<UserProvider>().roleName;

    return ChangeNotifierProvider(
      create: (_) => LemburProvider(),
      builder: (context, _) {
        context.watch<LemburProvider>();
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
                                label: 'Nama', value: lembur.user['nama']),
                            DetailItem(
                                label: 'Status',
                                value: lembur.status,
                                color: lembur.statusColor),
                            DetailItem(
                                label: 'Tanggal Mulai',
                                value: DateHelper.format(lembur.tanggal)),
                            DetailItem(
                                label: 'Jam Mulai',
                                value:
                                    FormatTime().formatTime(lembur.jamMulai)),
                            DetailItem(
                                label: 'Jam Selesai',
                                value:
                                    FormatTime().formatTime(lembur.jamSelesai)),
                            DetailItem(
                                label: 'Alasan', value: lembur.deskripsi),
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
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row nama + status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lembur.user['nama'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: AppColors.putih,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: lembur.statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                lembur.status,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  color: lembur.statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tanggal + Jam
                      Text(
                        '${DateHelper.format(lembur.tanggal)} ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.putih,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '(${FormatTime().formatTime(lembur.jamMulai)} - ${FormatTime().formatTime(lembur.jamSelesai)})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.putih,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Deskripsi singkat
                      Text(
                        lembur.shortDeskripsi,
                        style: GoogleFonts.poppins(
                          color: AppColors.putih,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // =================== ACTION BUTTONS ===================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (lembur.isPending) ...[
                      // Semua role boleh Approve & Decline
                      ActionButton(
                        label: 'Decline',
                        color: AppColors.red,
                        onTap: () => onDecline(),
                      ),
                      ActionButton(
                        label: 'Approve',
                        color: AppColors.green,
                        onTap: () => onApprove(),
                      ),
                    ] else if (lembur.isProses) ...[
                      // Selain Admin Office → tetep Approve & Decline
                      ActionButton(
                        label: 'Decline',
                        color: AppColors.red,
                        onTap: () => onDecline(),
                      ),
                      ActionButton(
                        label: 'Approve',
                        color: AppColors.green,
                        onTap: () => onApprove(),
                      ),
                    ] else ...[
                      // Admin Office pas Proses, atau status lain → Edit & Delete
                      ActionButton(
                        label: 'Delete',
                        color: AppColors.red,
                        onTap: () => onDelete(),
                      ),
                      ActionButton(
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

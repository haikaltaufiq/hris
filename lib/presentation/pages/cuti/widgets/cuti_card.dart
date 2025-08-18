import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/update_status_dialog.dart';
import 'package:hr/components/button/action_button.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/provider/function/cuti_provider.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/provider/features/features_guard.dart';
import 'package:hr/presentation/pages/cuti/cuti_form/cuti_edit_form.dart';

class CutiCard extends StatelessWidget {
  final CutiModel cuti;
  final Future<void> Function() onApprove;
  final Future<void> Function() onDecline;
  final VoidCallback onDelete;

  const CutiCard({
    super.key,
    required this.cuti,
    required this.onApprove,
    required this.onDecline,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                        title: Text('Detail Cuti',
                            style: GoogleFonts.poppins(
                                color: AppColors.putih,
                                fontWeight: FontWeight.w600)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DetailItem(label: 'Nama', value: cuti.user['nama']),
                            DetailItem(
                                label: 'Status',
                                value: cuti.status,
                                color: cuti.statusColor),
                            DetailItem(
                                label: 'Tipe Cuti', value: cuti.tipe_cuti),
                            DetailItem(
                                label: 'Tanggal Mulai',
                                value: DateHelper.format(cuti.tanggal_mulai)),
                            DetailItem(
                                label: 'Tanggal Selesai',
                                value: DateHelper.format(cuti.tanggal_selesai)),
                            DetailItem(label: 'Alasan', value: cuti.alasan),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tutup',
                                style: GoogleFonts.poppins(
                                    color: AppColors.putih)),
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cuti.isPending) ...[
                      FeatureGuard(
                        featureId: 'decline_cuti',
                        child: ActionButton(
                            label: 'Decline',
                            color: AppColors.red,
                            onTap: () => onDecline()),
                      ),
                      FeatureGuard(
                        featureId: 'approve_cuti',
                        child: ActionButton(
                            label: 'Approve',
                            color: AppColors.green,
                            onTap: () => onApprove()),
                      ),
                    ] else ...[
                      FeatureGuard(
                        featureId: 'delete_cuti',
                        child: ActionButton(
                            label: 'Delete',
                            color: AppColors.red,
                            onTap: () => onDelete()),
                      ),
                      FeatureGuard(
                        featureId: 'edit_cuti',
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
                            }),
                      ),
                    ],
                    FeatureGuard(
                      featureId: 'user_delete_cuti',
                      child: ActionButton(
                        label: 'Delete',
                        color: AppColors.red,
                        onTap: () => onDelete(),
                      ),
                    ),
                    FeatureGuard(
                      featureId: 'user_edit_cuti',
                      child: ActionButton(
                          label: 'Edit',
                          color: AppColors.yellow,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CutiEditForm(cuti: cuti)),
                            );
                          }),
                    ),
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

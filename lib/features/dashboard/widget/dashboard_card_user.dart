import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/kantor_model.dart';
import 'package:hr/data/services/jam_kantor.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_keluar_page.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_masuk_page.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardCardUser extends StatefulWidget {
  const DashboardCardUser({super.key});

  @override
  State<DashboardCardUser> createState() => _DashboardCardUserState();
}

class _DashboardCardUserState extends State<DashboardCardUser> {
  KantorModel? kantor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKantorData();
  }

  Future<void> _loadKantorData() async {
    try {
      final data = await JamKantor.getKantor();
      if (mounted) {
        setState(() {
          kantor = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error loading kantor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // tipis banget
            blurRadius: 4, // kecil, biar soft
            spreadRadius: 0,
            offset: Offset(0, 1), // cuma bawah dikit
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.calendarCheck,
                    color: AppColors.putih,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Attendance",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.putih,
                        ),
                      ),
                      Text(
                        "Track your work schedule",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.putih.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.putih.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    DateFormat('dd MMM, yyyy')
                        .format(DateTime.now()), // contoh: Aug 14, 2025
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.putih.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Work Schedule Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.putih.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.clock,
                    color: AppColors.putih.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Work Hours: ",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.putih.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    kantor != null
                        ? "${kantor!.jamMasuk} - ${kantor!.jamKeluar}"
                        : "08:00 - 17:00",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.putih,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Active",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // tipis banget
                          blurRadius: 4, // kecil, biar soft
                          spreadRadius: 0,
                          offset: Offset(0, 1), // cuma bawah dikit
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final absenProvider = context.read<AbsenProvider>();
                          if (!absenProvider.hasCheckedInToday) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AbsenMasukPage(),
                              ),
                            );
                          } else {
                            NotificationHelper.showTopNotification(
                                context, "Anda Sudah Check-in hari ini",
                                isSuccess: false);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.rightToBracket,
                              color: AppColors.putih,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Clock In",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.putih,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.putih.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final absenProvider = context.read<AbsenProvider>();
                          if (absenProvider.hasCheckedInToday) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AbsenKeluarPage(),
                              ),
                            );
                          } else {
                            NotificationHelper.showTopNotification(
                                context, "Anda Belum Check-in hari ini",
                                isSuccess: false);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.rightFromBracket,
                              color: AppColors.putih.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Clock Out",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.putih.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/kantor_model.dart';
import 'package:hr/data/services/jam_kantor.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_keluar_page.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_masuk_page.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CardAttendance extends StatefulWidget {
  const CardAttendance({super.key});

  @override
  State<CardAttendance> createState() => _CardAttendanceUserState();
}

class _CardAttendanceUserState extends State<CardAttendance> {
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
      // print('Error loading kantor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================
            // TIME & DATE SECTION
            // =====================
            Center(
              child: Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.putih,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE, dd MMMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.putih.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  //
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Action Buttons
            FeatureGuard(
              requiredFeature: "lihat_absensi_sendiri",
              child: Row(
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
                            color:
                                Colors.black.withOpacity(0.05), // tipis banget
                            blurRadius: 4, // kecil, biar soft
                            spreadRadius: 0,
                            offset: Offset(0, 1), // cuma bawah dikit
                          ),
                        ],
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
                            if (!absenProvider.hasCheckedInToday) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AbsenMasukPage(),
                                ),
                              );
                            } else {
                              final message = context.isIndonesian
                                  ? "Anda Sudah Check-in hari ini"
                                  : "You have already checked in today";
                              NotificationHelper.showTopNotification(
                                  context, message,
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
                                context.isIndonesian
                                    ? "Masuk Kerja"
                                    : "Clock In",
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
                              final message = context.isIndonesian
                                  ? "Anda Belum Check-in hari ini"
                                  : "You haven't checked in today";
                              NotificationHelper.showTopNotification(
                                  context, message,
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
                                context.isIndonesian
                                    ? "Keluar Kerja"
                                    : "Clock Out",
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
            ),
          ],
        ),
      ),
    );
  }
}

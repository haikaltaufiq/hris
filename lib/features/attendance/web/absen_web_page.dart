import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/attendance/widget/absen_web_tabel.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class AbsenWebPage extends StatefulWidget {
  const AbsenWebPage({super.key});

  @override
  State<AbsenWebPage> createState() => _AbsenWebPageState();
}

class _AbsenWebPageState extends State<AbsenWebPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AbsenProvider>();
      if (provider.absensi.isEmpty) {
        provider.loadCacheFirst();
        provider.fetchAbsensi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final absenProvider = context.watch<AbsenProvider>();
    final absen = searchController.text.isEmpty
        ? absenProvider.absensi
        : absenProvider.filteredAbsensi;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SearchingBar(
                controller: searchController,
                onChanged: (query) => absenProvider.searchAbsensi(query),
                onFilter1Tap: () {},
              ),
              const SizedBox(height: 5),
              if (absenProvider.isLoading && absen.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: LoadingWidget()),
                )
              else if (absenProvider.absensi.isEmpty &&
                  !absenProvider.isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: AppColors.putih.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.isIndonesian
                              ? 'Belum ada Absensi'
                              : "No Attendance available",
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AbsenTabelWeb(absensi: absen),
                ),
            ],
          ),
          FeatureGuard(
            requiredFeature: 'lihat_absensi_sendiri',
            child: Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierColor: Colors.black.withOpacity(0.6),
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 400,
                            minWidth: 320,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header with icon
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.clock,
                                    color: AppColors.putih,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Title
                                Text(
                                  context.isIndonesian
                                      ? "Absensi"
                                      : "Attendance Action",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.putih,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: -0.5,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Subtitle
                                Text(
                                  context.isIndonesian
                                      ? "Pilih jenis absensi anda"
                                      : "Choose your attendance option",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.putih.withOpacity(0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Clock In Button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.green,
                                        AppColors.green.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.green.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final absenProvider =
                                            context.read<AbsenProvider>();
                                        if (!absenProvider.hasCheckedInToday) {
                                          Navigator.of(context).pop();
                                          final result =
                                              await Navigator.pushNamed(
                                                  context, AppRoutes.checkin);
                                          if (result == true) {
                                            await context
                                                .read<AbsenProvider>()
                                                .fetchAbsensi();
                                          }
                                        } else {
                                          NotificationHelper.showTopNotification(
                                              context,
                                              "Anda Sudah Check-in hari ini",
                                              isSuccess: false);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.login,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    context.isIndonesian
                                                        ? "Masuk"
                                                        : "Clock In",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    context.isIndonesian
                                                        ? "Mulai hari kerja Anda"
                                                        : "Start your workday",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              FontAwesomeIcons.chevronRight,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Clock Out Button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.red,
                                        AppColors.red.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.red.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final absenProvider =
                                            context.read<AbsenProvider>();
                                        if (absenProvider.hasCheckedInToday) {
                                          Navigator.of(context).pop();
                                          final result =
                                              await Navigator.pushNamed(
                                                  context, AppRoutes.checkout);
                                          if (result == true) {
                                            await context
                                                .read<AbsenProvider>()
                                                .fetchAbsensi();
                                          }
                                        } else {
                                          NotificationHelper.showTopNotification(
                                              context,
                                              "Anda Belum Check-in hari ini",
                                              isSuccess: false);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.logout,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    context.isIndonesian
                                                        ? "Keluar"
                                                        : "Clock Out",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    context.isIndonesian
                                                        ? "Akhiri Hari kerja anda"
                                                        : "End your workday",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              FontAwesomeIcons.chevronRight,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Cancel button
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    context.isIndonesian ? "Batal" : "Cancel",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.putih.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                backgroundColor: AppColors.secondary,
                elevation: 8,
                shape: const CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.plus,
                    color: AppColors.putih,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

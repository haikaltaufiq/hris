import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_keluar_page.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_masuk_page.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/attendance/widget/absen_excel_export.dart';
import 'package:hr/features/attendance/widget/absen_tabel.dart';
import 'package:provider/provider.dart';

class AbsenMobile extends StatefulWidget {
  const AbsenMobile({super.key});

  @override
  State<AbsenMobile> createState() => _AbsenMobileState();
}

class _AbsenMobileState extends State<AbsenMobile> {
  final searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AbsenProvider>();
      provider.loadCacheFirst(); // Load cache first
      provider.fetchAbsensi(); // Then fetch from API
    });
  }

  Future<void> _refreshData() async {
    await context.read<AbsenProvider>().fetchAbsensi(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AbsenProvider>();
    final displayedAbsensi = provider.filteredAbsensi.isEmpty
        ? provider.absensi
        : provider.filteredAbsensi;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  Header(title: "Attendance Management"),
                  SearchingBar(
                    controller: searchController,
                    onChanged: (value) {
                      provider.searchAbsensi(value);
                    },
                    onFilter1Tap: () {},
                  ),
                  AbsenExcelExport(),
                  if (provider.isLoading && displayedAbsensi.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: LoadingWidget()),
                    )
                  else if (provider.absensi.isEmpty && !provider.isLoading)
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
                              'Belum ada Absensi',
                              style: TextStyle(
                                color: AppColors.putih,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap tombol + untuk menambah pengajuan baru',
                              style: TextStyle(
                                color: AppColors.putih.withOpacity(0.7),
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: displayedAbsensi.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final absen = displayedAbsensi[index];
                        return AbsenTabel(
                          absensi: absen,
                        );
                      },
                    )
                ],
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
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
                                      color:
                                          AppColors.secondary.withOpacity(0.3),
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
                                "Attendance Action",
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
                                "Choose your attendance option",
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
                                      Navigator.of(context).pop();
                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AbsenMasukPage(),
                                        ),
                                      );
                                      if (result == true) {
                                        await _refreshData();
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
                                              color:
                                                  Colors.white.withOpacity(0.2),
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
                                                  "Clock In",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  "Start your workday",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
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
                                      Navigator.of(context).pop();
                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AbsenKeluarPage(),
                                        ),
                                      );
                                      if (result == true) {
                                        await _refreshData();
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
                                              color:
                                                  Colors.white.withOpacity(0.2),
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
                                                  "Clock Out",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  "End your workday",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
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
                                  "Cancel",
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
        ],
      ),
    );
  }
}

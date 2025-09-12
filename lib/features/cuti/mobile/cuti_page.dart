// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/features/cuti/cuti_form/cuti_form.dart';
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
import 'package:hr/features/cuti/widgets/cuti_card.dart';
import 'package:hr/features/cuti/widgets/user_cuti_tabel.dart';
import 'package:provider/provider.dart';

class CutiPageMobile extends StatefulWidget {
  const CutiPageMobile({super.key});

  @override
  State<CutiPageMobile> createState() => _CutiPageMobileState();
}

class _CutiPageMobileState extends State<CutiPageMobile> {
  final searchController = TextEditingController();
  bool isAscending = true;

  @override
  void initState() {
    super.initState();

    // Load cache immediately (synchronous)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CutiProvider>();
      provider.loadCacheFirst(); // Load cache first
      provider.fetchCuti(); // Then fetch from API
    });
  }

  Future<void> _refreshData() async {
    await context.read<CutiProvider>().fetchCuti(forceRefresh: true);
  }

  Future<void> _deleteCuti(CutiModel cuti) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Hapus",
      content: "Apakah Anda yakin ingin menghapus cuti ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message =
          await context.read<CutiProvider>().deleteCuti(cuti.id, "");
      searchController.clear();

      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: message != "",
      );
    }
  }

  Future<void> _approveCuti(CutiModel cuti) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Persetujuan",
      content: "Apakah Anda yakin ingin menyetujui cuti ini?",
      confirmText: "Setuju",
      cancelText: "Batal",
      confirmColor: AppColors.green,
    );

    if (confirmed) {
      try {
        final message =
            await context.read<CutiProvider>().approveCuti(cuti.id, "");

        searchController.clear();

        NotificationHelper.showTopNotification(
          context,
          message!,
          isSuccess: true,
        );
      } catch (e) {
        // kalau gagal (error dari API)
        NotificationHelper.showTopNotification(
          context,
          e.toString(),
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _declineCuti(CutiModel cuti) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Penolakan",
      content: "Apakah Anda yakin ingin menolak cuti ini?",
      confirmText: "Tolak",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message =
          await context.read<CutiProvider>().declineCuti(cuti.id, "");
      searchController.clear();

      NotificationHelper.showTopNotification(
        context,
        message ?? 'Gagal menolak Cuti',
        isSuccess: message != null,
      );
    }
  }

  void _toggleSort() {
    setState(() {
      isAscending = !isAscending;

      final provider = context.read<CutiProvider>();
      final listToSort = searchController.text.isEmpty
          ? provider.cutiList
          : provider.filteredCutiList;

      listToSort.sort((a, b) {
        final dateA = DateTime.parse(a.tanggal_mulai);
        final dateB = DateTime.parse(b.tanggal_mulai);
        return isAscending
            ? dateA.compareTo(dateB) // Terlama → Terbaru
            : dateB.compareTo(dateA); // Terbaru → Terlama
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cutiProvider = context.watch<CutiProvider>();
    final displayedList = searchController.text.isEmpty
        ? cutiProvider.cutiList
        : cutiProvider.filteredCutiList;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
              ),
              child: ListView(
                children: [
                  const Header(title: 'Pengajuan Cuti'),
                  SearchingBar(
                    controller: searchController,
                    onChanged: (value) {
                      cutiProvider.filterCuti(value);
                    },
                    onFilter1Tap: _toggleSort,
                  ),

                  // Updated loading logic
                  if (cutiProvider.isLoading && displayedList.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: LoadingWidget()),
                    )
                  else if (displayedList.isEmpty && !cutiProvider.isLoading)
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
                              cutiProvider.errorMessage != null
                                  ? 'Gagal memuat data'
                                  : 'Belum ada pengajuan',
                              style: TextStyle(
                                color: AppColors.putih,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cutiProvider.errorMessage != null
                                  ? 'Tarik ke bawah untuk refresh'
                                  : 'Tap tombol + untuk menambah pengajuan baru',
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
                  else ...[
                    // FeatureGuard untuk Admin - melihat semua cuti
                    FeatureGuard(
                      requiredFeature: 'lihat_semua_cuti',
                      child: ListView.builder(
                        itemCount: displayedList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final cuti = displayedList[index];
                          return CutiCard(
                            cuti: cuti,
                            onApprove: () => _approveCuti(cuti),
                            onDecline: () => _declineCuti(cuti),
                            onDelete: () => _deleteCuti(cuti),
                          );
                        },
                      ),
                    ),

                    // FeatureGuard untuk User - melihat cuti sendiri saja
                    FeatureGuard(
                      requiredFeature: 'lihat_cuti_sendiri',
                      child: ListView.builder(
                        itemCount: displayedList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return UserCutiTabel(
                            cutiList: displayedList,
                            onDelete: (CutiModel cuti) {
                              _deleteCuti(cuti);
                            },
                          );
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),

          // FloatingActionButton untuk tambah cuti - tanpa FeatureGuard atau dengan FeatureGuard jika diperlukan
          Positioned(
            bottom: 16,
            right: 16,
            child: FeatureGuard(
              requiredFeature:
                  'tambah_cuti', // Tambahkan jika diperlukan role-based access
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CutiForm()),
                  );

                  if (result == true) {
                    _refreshData(); // Lebih baik gunakan _refreshData() daripada setState()
                  }
                },
                backgroundColor: AppColors.secondary,
                shape: const CircleBorder(),
                child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

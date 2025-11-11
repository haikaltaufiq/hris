// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/custom/sorting.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
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

  // Future<void> _deleteCuti(CutiModel cuti) async {
  //   final confirmed = await showConfirmationDialog(
  //     context,
  //     title: "Konfirmasi Hapus",
  //     content: "Apakah Anda yakin ingin menghapus cuti ini?",
  //     confirmText: "Hapus",
  //     cancelText: "Batal",
  //     confirmColor: AppColors.red,
  //   );

  //   if (confirmed) {
  //     final message =
  //         await context.read<CutiProvider>().deleteCuti(cuti.id, "");
  //     searchController.clear();

  //     NotificationHelper.showTopNotification(
  //       context,
  //       message,
  //       isSuccess: message != "",
  //     );
  //   }
  // }

  Future<void> _approveCuti(CutiModel cuti) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: context.isIndonesian
          ? "Konfirmasi Persetujuan"
          : "Approval Confirmation",
      content: context.isIndonesian
          ? "Apakah Anda yakin ingin menyetujui cuti ini?"
          : "Are you sure want to approve this leave proposal?",
      confirmText: context.isIndonesian ? "Setuju" : "Approve",
      cancelText: context.isIndonesian ? "Batal" : "Cancel",
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
    final catatanPenolakanController = TextEditingController();
    String? catatanPenolakan;

    // Step 1: Dialog isi alasan
    final isiAlasan = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            context.isIndonesian ? "Alasan Penolakan" : "Reason for Rejection",
            style: GoogleFonts.poppins(
              color: AppColors.putih,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width *
                (context.isMobile
                    ? 0.9
                    : 0.4), // mobile lebih lebar, desktop ideal
            child: TextFormField(
              controller: catatanPenolakanController,
              style: TextStyle(color: AppColors.putih),
              decoration: InputDecoration(
                hintText: context.isIndonesian
                    ? "Tuliskan alasan penolakan..."
                    : "Write your reason...",
                hintStyle: TextStyle(color: AppColors.putih.withOpacity(0.6)),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.putih.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.isIndonesian ? "Batal" : "Cancel",
                  style: GoogleFonts.poppins(color: AppColors.putih)),
            ),
            TextButton(
              onPressed: () {
                if (catatanPenolakanController.text.trim().isNotEmpty) {
                  catatanPenolakan = catatanPenolakanController.text.trim();
                  Navigator.pop(context, true);
                }
              },
              child: Text(context.isIndonesian ? "Lanjut" : "Continue",
                  style: GoogleFonts.poppins(color: AppColors.red)),
            ),
          ],
        );
      },
    );

    if (isiAlasan != true || catatanPenolakan == null) return;

    // Step 2: Konfirmasi submit
    final confirmed = await showConfirmationDialog(
      context,
      title: context.isIndonesian
          ? "Konfirmasi Penolakan"
          : "Rejection Confirmation",
      content: context.isIndonesian
          ? "Apakah Anda yakin ingin menolak cuti ini?"
          : "Are you sure want to reject this leave proposal?",
      confirmText: context.isIndonesian ? "Tolak" : "Reject",
      cancelText: context.isIndonesian ? "Batal" : "Cancel",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message = await context
          .read<CutiProvider>()
          .declineCuti(cuti.id, catatanPenolakan!);

      searchController.clear();
      final messages = context.isIndonesian
          ? 'Gagal menolak Cuti'
          : 'Failed to reject Leave';
      NotificationHelper.showTopNotification(
        context,
        message ?? messages,
        isSuccess: message != null,
      );
    }
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
            color: AppColors.putih,
            backgroundColor: AppColors.bg,
            onRefresh: _refreshData,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
              ),
              child: ListView(
                children: [
                  Header(
                      title: context.isIndonesian
                          ? 'Pengajuan Cuti'
                          : 'Leave Proposal'),
                  SearchingBar(
                    controller: searchController,
                    onChanged: (value) {
                      cutiProvider.filterCuti(value);
                    },
                    onFilter1Tap: () async {
                      final provider = context.read<CutiProvider>();

                      // bangun dulu options
                      final options = [
                        {
                          'value': 'terbaru',
                          'label': context.isIndonesian ? 'Terbaru' : 'Newest',
                        },
                        {
                          'value': 'terlama',
                          'label': context.isIndonesian ? 'Terlama' : 'Oldest',
                        },
                        {
                          'value': 'status',
                          'label': 'Status',
                        },
                      ];

                      // guard fitur
                      if (FeatureAccess.has('approve_cuti')) {
                        options.add({
                          'value': 'per-orang',
                          'label':
                              context.isIndonesian ? 'Per-orang' : 'By Person',
                        });
                      }

                      if (FeatureAccess.has('approve_cuti')) {
                        options.add({
                          'value': 'nama',
                          'label': context.isIndonesian
                              ? 'Nama Karyawan'
                              : 'Employee Name',
                        });
                      }

                      // baru panggil dialog
                      final selected = await showSortDialog(
                        context: context,
                        title: context.isIndonesian
                            ? 'Urutkan Berdasarkan'
                            : 'Sort Leave By',
                        currentValue: provider.currentSortField,
                        options: options,
                      );

                      if (selected != null) {
                        provider.sortCuti(selected);
                      }
                    },
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
                                  ? context.isIndonesian
                                      ? 'Gagal memuat data'
                                      : 'Failed to load data'
                                  : context.isIndonesian
                                      ? 'Belum ada pengajuan'
                                      : 'No leave proposals yet',
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
                                  ? context.isIndonesian
                                      ? 'Tarik ke bawah untuk refresh'
                                      : 'Pull down to refresh'
                                  : context.isIndonesian
                                      ? 'Tap tombol + untuk menambah pengajuan baru'
                                      : 'Tap the + button to add a new leave proposal',
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
                            // onDelete: () => _deleteCuti(cuti),
                          );
                        },
                      ),
                    ),

                    // FeatureGuard untuk User - melihat cuti sendiri saja
                    FeatureGuard(
                      requiredFeature: 'lihat_cuti_sendiri',
                      child: UserCutiTabel(
                        cutiList: displayedList,
                        onDelete: (CutiModel cuti) {
                          // _deleteCuti(cuti);
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

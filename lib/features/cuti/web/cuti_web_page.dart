// ignore_for_file: non_constant_identifier_names, annotate_overrides, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
import 'package:hr/features/cuti/web/web_tabel_cuti.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class CutiWebPage extends StatefulWidget {
  const CutiWebPage({super.key});

  @override
  State<CutiWebPage> createState() => _CutiWebPageState();
}

class _CutiWebPageState extends State<CutiWebPage> {
  final searchController = TextEditingController();
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CutiProvider>();
      provider.loadCacheFirst(); // Load cache first
      provider.fetchCuti(); // Then fetch from API
    });
  }

  // Future<void> _deleteCuti(CutiModel cuti) async {
  //   final confirmed = await showConfirmationDialog(
  //     context,
  //     title: "Konfirmasi Hapus",
  //     content: "Apakah Anda yakin ingin menghapus Cuti ini?",
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
    final catatanPenolakanController = TextEditingController();
    String? catatan_penolakan;

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
                  catatan_penolakan = catatanPenolakanController.text.trim();
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

    if (isiAlasan != true || catatan_penolakan == null) return;

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
          .declineCuti(cuti.id, catatan_penolakan!);

      searchController.clear();

      NotificationHelper.showTopNotification(
        context,
        message ?? 'Gagal menolak Cuti',
        isSuccess: message != null,
      );
    }
  }

  Widget build(BuildContext context) {
    final cutiProvider = context.watch<CutiProvider>();
    final displayedList = searchController.text.isEmpty
        ? cutiProvider.cutiList
        : cutiProvider.filteredCutiList;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              SearchingBar(
                controller: searchController,
                onChanged: (value) {
                  cutiProvider.filterCuti(value);
                },
                onFilter1Tap: () async {
                  final provider = context.read<CutiProvider>();

                  final selected = await showSortDialog(
                    context: context,
                    title: 'Urutkan Cuti Berdasarkan',
                    currentValue: provider.currentSortField,
                    options: [
                      {'value': 'terbaru', 'label': 'Terbaru'},
                      {'value': 'terlama', 'label': 'Terlama'},
                      {'value': 'nama', 'label': 'Nama Karyawan'},
                      {'value': 'status', 'label': 'Status'},
                    ],
                  );

                  if (selected != null) {
                    provider.sortCuti(selected);
                  }
                },
              ),
              if (cutiProvider.isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: LoadingWidget()),
                )
              else if (cutiProvider.errorMessage != null)
                Center(child: Text('Error: ${cutiProvider.errorMessage}'))
              else if (displayedList.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty,
                            size: 64, color: AppColors.putih.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          context.isIndonesian
                              ? 'Belum ada pengajuan'
                              : 'No leave proposal available',
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WebTabelCuti(
                    cutiList: displayedList,
                    // onDelete: _deleteCuti,
                    onApprove: (cuti) => _approveCuti(cuti),
                    onDecline: (cuti) => _declineCuti(cuti),
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FeatureGuard(
              requiredFeature:
                  'tambah_cuti', // Tambahkan jika diperlukan role-based access
              child: FloatingActionButton(
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, AppRoutes.cutiForm);

                  if (result == true) {
                    await context.read<CutiProvider>().fetchCuti();
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
}

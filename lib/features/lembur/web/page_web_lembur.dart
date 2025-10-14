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
import 'package:hr/data/models/lembur_model.dart';
import 'package:hr/features/lembur/lembur_viewmodel/lembur_provider.dart';
import 'package:hr/features/lembur/web/web_tabel.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LemburWebPage extends StatefulWidget {
  const LemburWebPage({super.key});

  @override
  State<LemburWebPage> createState() => _LemburWebPageState();
}

class _LemburWebPageState extends State<LemburWebPage> {
  final searchController = TextEditingController();
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    // Load cache immediately (synchronous)

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LemburProvider>();
      provider.loadCacheFirst(); // Load cache first
      provider.fetchLembur(); // Then fetch from API
    });
  }

  // Future<void> _deleteLembur(LemburModel lembur) async {
  //   final confirmed = await showConfirmationDialog(
  //     context,
  //     title: "Konfirmasi Hapus",
  //     content: "Apakah Anda yakin ingin menghapus lembur ini?",
  //     confirmText: "Hapus",
  //     cancelText: "Batal",
  //     confirmColor: AppColors.red,
  //   );

  //   if (confirmed) {
  //     final message =
  //         await context.read<LemburProvider>().deleteLembur(lembur.id, "");
  //     searchController.clear();

  //     NotificationHelper.showTopNotification(
  //       context,
  //       message!,
  //       isSuccess: message != "",
  //     );
  //   }
  // }

  Future<void> _approveLembur(LemburModel lembur) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Persetujuan",
      content: "Apakah Anda yakin ingin menyetujui lembur ini?",
      confirmText: "Setuju",
      cancelText: "Batal",
      confirmColor: AppColors.green,
    );

    if (confirmed) {
      try {
        final message =
            await context.read<LemburProvider>().approveLembur(lembur.id, "");

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

  Future<void> _declineLembur(LemburModel lembur) async {
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
            context.isIndonesian ? "Catatan Penolakan" : "Rejection Note",
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
                    : "Write the reason of rejection",
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
              child: Text("Batal",
                  style: GoogleFonts.poppins(color: AppColors.putih)),
            ),
            TextButton(
              onPressed: () {
                if (catatanPenolakanController.text.trim().isNotEmpty) {
                  catatanPenolakan = catatanPenolakanController.text.trim();
                  Navigator.pop(context, true);
                }
              },
              child: Text("Lanjut",
                  style: GoogleFonts.poppins(color: AppColors.red)),
            ),
          ],
        );
      },
    );

    if (isiAlasan != true || catatanPenolakan == null) return;

    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Penolakan",
      content: "Apakah Anda yakin ingin menolak lembur ini?",
      confirmText: "Tolak",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message = await context
          .read<LemburProvider>()
          .declineLembur(lembur.id, catatanPenolakan!);
      searchController.clear();

      NotificationHelper.showTopNotification(
        context,
        message ?? 'Gagal menolak lembur',
        isSuccess: message != null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lemburProvider = context.watch<LemburProvider>();
    final displayedList = searchController.text.isEmpty
        ? lemburProvider.lemburList
        : lemburProvider.filteredLemburList;
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
                  lemburProvider.filterLembur(value);
                },
                onFilter1Tap: () async {
                  final provider = context.read<LemburProvider>();

                  final selected = await showSortDialog(
                    context: context,
                    title: 'Urutkan Lembur Berdasarkan',
                    currentValue: provider.currentSortField,
                    options: [
                      {'value': 'terbaru', 'label': 'Terbaru'},
                      {'value': 'terlama', 'label': 'Terlama'},
                      {'value': 'nama', 'label': 'Nama Karyawan'},
                      {'value': 'status', 'label': 'Status'},
                    ],
                  );

                  if (selected != null) {
                    provider.sortLembur(selected);
                  }
                },
              ),
              if (lemburProvider.isLoading && displayedList.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: LoadingWidget()),
                )
              else if (lemburProvider.errorMessage != null)
                Center(child: Text('Error: ${lemburProvider.errorMessage}'))
              else if (lemburProvider.lemburList.isEmpty &&
                  !lemburProvider.isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 64,
                          color: AppColors.putih.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.isIndonesian
                              ? 'Belum ada pengajuan'
                              : "No proposal available",
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.isIndonesian
                              ? 'Tap tombol + untuk menambah pengajuan baru'
                              : ' Press + button to add new proposal',
                          style: TextStyle(
                            color: AppColors.putih.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else if (displayedList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WebTabelLembur(
                    lemburList: displayedList,
                    // onDelete: _deleteLembur,
                    onApprove: (lembur) => _approveLembur(lembur),
                    onDecline: (lembur) => _declineLembur(lembur),
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FeatureGuard(
              requiredFeature: 'tambah_lembur',
              child: FloatingActionButton(
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, AppRoutes.lemburForm);

                  if (result == true) {
                    setState(() {});
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

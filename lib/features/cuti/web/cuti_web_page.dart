import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
import 'package:hr/features/cuti/web/web_tabel_cuti.dart';
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

  Future<void> _deleteCuti(CutiModel cuti) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Hapus",
      content: "Apakah Anda yakin ingin menghapus Cuti ini?",
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
    final alasanController = TextEditingController();
    String? alasan;

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
            "Alasan Penolakan",
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
              controller: alasanController,
              style: TextStyle(color: AppColors.putih),
              decoration: InputDecoration(
                hintText: "Tuliskan alasan penolakan...",
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
                if (alasanController.text.trim().isNotEmpty) {
                  alasan = alasanController.text.trim();
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

    if (isiAlasan != true || alasan == null) return;

    // Step 2: Konfirmasi submit
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
          await context.read<CutiProvider>().declineCuti(cuti.id, alasan!);

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
        final dateB = DateTime.parse(b.tanggal_selesai);
        return isAscending
            ? dateA.compareTo(dateB) // Terlama → Terbaru
            : dateB.compareTo(dateA); // Terbaru → Terlama
      });
    });
  }

  Widget build(BuildContext context) {
    final cutiProvider = context.watch<CutiProvider>();
    final displayedList = searchController.text.isEmpty
        ? cutiProvider.cutiList
        : cutiProvider.filteredCutiList;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SearchingBar(
            controller: searchController,
            onChanged: (value) {
              cutiProvider.filterCuti(value);
            },
            onFilter1Tap: _toggleSort,
          ),
          if (cutiProvider.isLoading && displayedList.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(child: LoadingWidget()),
            )
          else if (cutiProvider.errorMessage != null)
            Center(child: Text('Error: ${cutiProvider.errorMessage}'))
          else if (cutiProvider.cutiList.isEmpty && !cutiProvider.isLoading)
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
                      'Belum ada pengajuan',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap tombol + untuk menambah pengajuan baru',
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
              child: WebTabelCuti(
                cutiList: displayedList,
                onDelete: _deleteCuti,
                onApprove: (cuti) => _approveCuti(cuti),
                onDecline: (cuti) => _declineCuti(cuti),
              ),
            ),
        ],
      ),
    );
  }
}

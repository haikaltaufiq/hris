import 'package:flutter/material.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/lembur_model.dart';
import 'package:hr/features/lembur/lembur_viewmodel/lembur_provider.dart';
import 'package:hr/features/lembur/web/web_tabel.dart';
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
    Future.microtask(() {
      context.read<LemburProvider>().fetchLembur();
    });
  }

  Future<void> _deleteLembur(LemburModel lembur) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Hapus",
      content: "Apakah Anda yakin ingin menghapus lembur ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message =
          await context.read<LemburProvider>().deleteLembur(lembur.id, "");
      searchController.clear();

      NotificationHelper.showTopNotification(
        context,
        message!,
        isSuccess: message != "",
      );
    }
  }

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
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Penolakan",
      content: "Apakah Anda yakin ingin menolak lembur ini?",
      confirmText: "Tolak",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed) {
      final message =
          await context.read<LemburProvider>().declineLembur(lembur.id, "");
      searchController.clear();

      NotificationHelper.showTopNotification(
        context,
        message ?? 'Gagal menolak lembur',
        isSuccess: message != null,
      );
    }
  }

  void _toggleSort() {
    setState(() {
      isAscending = !isAscending;

      final provider = context.read<LemburProvider>();
      final listToSort = searchController.text.isEmpty
          ? provider.lemburList
          : provider.filteredLemburList;

      listToSort.sort((a, b) {
        final dateA = DateTime.parse(a.tanggal);
        final dateB = DateTime.parse(b.tanggal);
        return isAscending
            ? dateA.compareTo(dateB) // Terlama → Terbaru
            : dateB.compareTo(dateA); // Terbaru → Terlama
      });
    });
  }

  Widget build(BuildContext context) {
    final lemburProvider = context.watch<LemburProvider>();
    final displayedList = searchController.text.isEmpty
        ? lemburProvider.lemburList
        : lemburProvider.filteredLemburList;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SearchingBar(
            controller: searchController,
            onChanged: (value) {
              lemburProvider.filterLembur(value);
            },
            onFilter1Tap: _toggleSort,
          ),
          if (lemburProvider.isLoading)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(child: LoadingWidget()),
            )
          else if (lemburProvider.errorMessage != null)
            Center(child: Text('Error: ${lemburProvider.errorMessage}'))
          else if (lemburProvider.lemburList.isEmpty)
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
          // ganti bagian ListView.builder lu jadi kayak gini:
          else if (displayedList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WebTabelLembur(
                lemburList: displayedList,
                onDelete: _deleteLembur,
                onApprove: (lembur) => _approveLembur(lembur),
                onDecline: (lembur) => _declineLembur(lembur),
              ),
            ),
        ],
      ),
    );
  }
}

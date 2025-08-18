import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/data/models/lembur_model.dart';
import 'package:hr/presentation/pages/lembur/lembur_form/lembur_form.dart';
import 'package:hr/presentation/pages/lembur/widgets/lembur_card.dart';
import 'package:hr/presentation/pages/lembur/widgets/lembur_user_card.dart';
import 'package:hr/provider/features/features_guard.dart';
import 'package:hr/provider/function/lembur_provider.dart';
import 'package:hr/provider/function/user_provider.dart';
import 'package:provider/provider.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {
  final searchController = TextEditingController();
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LemburProvider>().fetchLembur();
    });
  }

  Future<void> _refreshData() async {
    await context.read<LemburProvider>().fetchLembur();
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

      NotificationHelper.showSnackBar(
        context,
        message!,
        isSuccess: message != null,
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
      final message =
          await context.read<LemburProvider>().approveLembur(lembur.id, "");
      searchController.clear();
      NotificationHelper.showSnackBar(
        context,
        message ?? 'Gagal menyetujui lembur',
        isSuccess: message != null,
      );
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

      NotificationHelper.showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final lemburProvider = context.watch<LemburProvider>();
    final userProvider = context.watch<UserProvider>();
    final displayedList = searchController.text.isEmpty
        ? lemburProvider.lemburList
        : lemburProvider.filteredLemburList;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Header(title: 'Pengajuan Lembur'),
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
              else if (userProvider.hasFeature("approval_lembur"))
                ListView.builder(
                  itemCount: displayedList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final lembur = displayedList[index];
                    return FeatureGuard(
                      featureId: "approval_lembur",
                      child: LemburCard(
                        lembur: lembur,
                        onApprove: () => _approveLembur(lembur),
                        onDecline: () => _declineLembur(lembur),
                        onDelete: () => _deleteLembur(lembur),
                      ),
                    );
                  },
                )
              else
                UserLemburTabel(
                  lemburList: displayedList,
                  onDelete: (lembur) => _deleteLembur(lembur),
                ),
            ],
          ),
        ),
        FeatureGuard(
          featureId: "add_lembur",
          child: Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LemburForm()),
                );

                if (result == true) {
                  context.read<LemburProvider>().fetchLembur();
                }
              },
              backgroundColor: AppColors.secondary,
              shape: const CircleBorder(),
              child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
            ),
          ),
        ),
      ],
    );
  }
}

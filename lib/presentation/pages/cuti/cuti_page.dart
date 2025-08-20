// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/cuti/cuti_form/cuti_form.dart';
import 'package:hr/presentation/pages/cuti/widgets/cuti_card.dart';
import 'package:hr/presentation/pages/cuti/widgets/user_cuti_tabel.dart';
import 'package:hr/provider/function/cuti_provider.dart';
import 'package:hr/provider/features/features_guard.dart';
import 'package:hr/provider/function/user_provider.dart';
import 'package:provider/provider.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  final searchController = TextEditingController();
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CutiProvider>().fetchCuti();
    });
  }

  Future<void> _refreshData() async {
    await context.read<CutiProvider>().fetchCuti();
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

      NotificationHelper.showSnackBar(
        context,
        message,
        isSuccess: message != null,
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

        NotificationHelper.showSnackBar(
          context,
          message!,
          isSuccess: true,
        );
      } catch (e) {
        // kalau gagal (error dari API)
        NotificationHelper.showSnackBar(
          context,
          e.toString(), // tampilkan pesan error dari API
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

      NotificationHelper.showSnackBar(
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
    final userProvider = context.watch<UserProvider>();
    final displayedList = searchController.text.isEmpty
        ? cutiProvider.cutiList
        : cutiProvider.filteredCutiList;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Header(title: 'Pengajuan Cuti'),
              SearchingBar(
                controller: searchController,
                onChanged: (value) {
                  cutiProvider.filterCuti(value);
                },
                onFilter1Tap: _toggleSort,
              ),
              if (cutiProvider.isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: LoadingWidget()),
                )
              else if (cutiProvider.cutiList.isEmpty)
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
              else if (userProvider.hasFeature("approval_card"))
                ListView.builder(
                  itemCount: displayedList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final cuti = displayedList[index];
                    return FeatureGuard(
                      featureId: "approval_card",
                      child: CutiCard(
                        cuti: cuti,
                        onApprove: () => _approveCuti(cuti),
                        onDecline: () => _declineCuti(cuti),
                        onDelete: () => _deleteCuti(cuti),
                      ),
                    );
                  },
                )
              else
                UserCutiTabel(
                  cutiList: displayedList,
                  onDelete: (cuti) => _deleteCuti(cuti),
                ),
            ],
          ),
        ),
        FeatureGuard(
          featureId: "add_cuti",
          child: Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CutiForm()),
                );

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
    );
  }
}

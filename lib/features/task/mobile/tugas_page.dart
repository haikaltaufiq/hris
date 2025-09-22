import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/tugas_form/tugas_form.dart';
import 'package:hr/features/task/widgets/tugas_tabel.dart';
import 'package:hr/features/task/widgets/tugas_user_tabel.dart';
// Add missing import if TugasUserTabel exists in different file
// import 'package:hr/features/task/widgets/tugas_user_tabel.dart';

import 'package:provider/provider.dart';

class TugasMobile extends StatefulWidget {
  const TugasMobile({super.key});

  @override
  State<TugasMobile> createState() => _TugasMobileState();
}

class _TugasMobileState extends State<TugasMobile> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TugasProvider>();
      provider.loadCacheFirst(); // Load cache first
      provider.fetchTugas(); // Then fetch from API
    });
  }

  Future<void> _refreshData() async {
    await context.read<TugasProvider>().fetchTugas(forceRefresh: true);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TugasProvider>();
    final displayedTugas = provider.filteredTugasList.isEmpty
        ? provider.tugasList
        : provider.filteredTugasList;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RefreshIndicator(
              color: AppColors.putih,
              backgroundColor: AppColors.bg,
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  const Header(title: "Daftar Tugas"),
                  SearchingBar(
                    controller: searchController,
                    onChanged: provider.filterTugas,
                    onFilter1Tap: () {},
                  ),
                  FeatureGuard(
                    requiredFeature: 'lihat_semua_tugas',
                    child: TugasTabel(
                      tugasList: displayedTugas,
                      onActionDone: () => searchController.clear(),
                    ),
                  ),
                  if (provider.isLoading && displayedTugas.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: LoadingWidget()),
                    )
                  else if (provider.tugasList.isEmpty && !provider.isLoading)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 64,
                                color: AppColors.putih.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada tugas',
                              style: GoogleFonts.poppins(
                                color: AppColors.putih,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap tombol + untuk menambah tugas baru',
                              style: GoogleFonts.poppins(
                                color: AppColors.putih.withOpacity(0.7),
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
                      itemCount: displayedTugas.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final tugas = displayedTugas[index];
                        return TugasUserTabel(
                          tugasList: [tugas],
                          onActionDone: () => searchController.clear(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          FeatureGuard(
            requiredFeature: 'tambah_tugas',
            child: Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TugasForm(),
                    ),
                  );
                  searchController.clear();
                  if (result == true) _refreshData();
                },
                backgroundColor: AppColors.secondary,
                shape: const CircleBorder(),
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: AppColors.putih,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/tugas_form/tugas_form.dart';
import 'package:hr/features/task/widgets/tugas_tabel.dart';

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
    final tugasProvider = context.watch<TugasProvider>();
    // final userProvider = context.watch<UserProvider>(); // fix missing

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
                  Header(
                    title: 'Daftar Tugas',
                  ),
                  SearchingBar(
                    controller: searchController,
                    onChanged: (value) {
                      tugasProvider.filterTugas(value);
                    },
                    onFilter1Tap: () {},
                  ),
                  Consumer<TugasProvider>(
                    builder: (context, tugasProvider, child) {
                      final displayedList = searchController.text.isEmpty
                          ? tugasProvider.tugasList
                          : tugasProvider.filteredTugasList;

                      if (tugasProvider.isLoading && displayedList.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(child: LoadingWidget()),
                        );
                      }

                      if (tugasProvider.errorMessage != null) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error: ${tugasProvider.errorMessage}',
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(
                                      color: AppColors.putih,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (displayedList.isEmpty && !tugasProvider.isLoading) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: AppColors.putih.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada tugas',
                                  style: TextStyle(
                                    color: AppColors.putih,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap tombol + untuk menambah tugas baru',
                                  style: TextStyle(
                                    color: AppColors.putih.withOpacity(0.7),
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // if (userProvider.hasFeature(FeatureIds.manageTask)) {
                      return TugasTabel(
                        tugasList: displayedList,
                        onActionDone: () {
                          searchController.clear();
                        },
                      );
                      // } else {
                      //   return FeatureGuard(
                      //     featureId: "user_tabel_task",
                      //     child: 
                      //       },TugasUserTabel(
                      //       tugasList: displayedList,
                      //       onActionDone: () {
                      //         searchController.clear();
                      //     ),
                      //   );
                      // }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TugasForm()),
                );
                searchController.clear();
                if (result == true) _refreshData();
              },
              backgroundColor: AppColors.secondary,
              shape: const CircleBorder(),
              child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/tugas_form/tugas_form.dart';
import 'package:hr/features/task/widgets/tugas_tabel.dart';
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
    final displayedTugas = searchController.text.isEmpty
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
                  Header(title: context.isIndonesian ? "Daftar Tugas" : "Task"),
                  SearchingBar(
                    controller: searchController,
                    onChanged: provider.filterTugas,
                    onFilter1Tap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          String selected = provider.currentSortField;
                          return AlertDialog(
                            backgroundColor: AppColors.primary,
                            title: Text(
                              context.isIndonesian
                                  ? 'Urutkan Berdasarkan'
                                  : 'Sort By',
                              style: TextStyle(color: AppColors.putih),
                            ),
                            content: StatefulBuilder(
                              builder: (context, setState) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<String>(
                                    value: 'terbaru',
                                    groupValue: selected,
                                    onChanged: (v) =>
                                        setState(() => selected = v!),
                                    title: Text(
                                      context.isIndonesian
                                          ? 'Terbaru'
                                          : 'Newest',
                                      style: TextStyle(color: AppColors.putih),
                                    ),
                                    activeColor: AppColors.putih,
                                  ),
                                  RadioListTile<String>(
                                    value: 'terlama',
                                    groupValue: selected,
                                    onChanged: (v) =>
                                        setState(() => selected = v!),
                                    title: Text(
                                      context.isIndonesian
                                          ? 'Terlama'
                                          : 'Oldest',
                                      style: TextStyle(color: AppColors.putih),
                                    ),
                                    activeColor: AppColors.putih,
                                  ),
                                  FeatureGuard(
                                    requiredFeature: 'tambah_tugas',
                                    child: RadioListTile<String>(
                                      value: 'nama',
                                      groupValue: selected,
                                      onChanged: (v) =>
                                          setState(() => selected = v!),
                                      title: Text(
                                        context.isIndonesian
                                            ? 'Per-orang'
                                            : 'By Person',
                                        style:
                                            TextStyle(color: AppColors.putih),
                                      ),
                                      activeColor: AppColors.putih,
                                    ),
                                  ),
                                  RadioListTile<String>(
                                    value: 'status',
                                    groupValue: selected,
                                    onChanged: (v) =>
                                        setState(() => selected = v!),
                                    title: Text(
                                      'Status',
                                      style: TextStyle(color: AppColors.putih),
                                    ),
                                    activeColor: AppColors.putih,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.putih,
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        minimumSize: const Size.fromHeight(
                                            50), // samakan tinggi
                                      ),
                                      child: Text(context.isIndonesian
                                          ? 'Batal'
                                          : 'Cancel'),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<TugasProvider>()
                                            .sortTugas(selected);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                        foregroundColor: AppColors.putih,
                                        minimumSize: const Size.fromHeight(50),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(context.isIndonesian
                                          ? 'Terapkan'
                                          : 'Apply'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
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
                              context.isIndonesian
                                  ? 'Belum ada tugas'
                                  : "No task available",
                              style: GoogleFonts.poppins(
                                color: AppColors.putih,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.isIndonesian
                                  ? 'Tap tombol + untuk menambah tugas baru'
                                  : 'Click + button to add new task',
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
                    TugasTabel(
                      tugasList: displayedTugas,
                      onActionDone: () => searchController.clear(),
                    )
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

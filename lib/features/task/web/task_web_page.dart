import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/features/task/web/task_tabel_web.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class TaskWebPage extends StatefulWidget {
  const TaskWebPage({super.key});

  @override
  State<TaskWebPage> createState() => _TaskWebPageState();
}

class _TaskWebPageState extends State<TaskWebPage> {
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
                  tugasProvider.filterTugas(value);
                },
                onFilter1Tap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String selected = tugasProvider.currentSortField;
                      return AlertDialog(
                        backgroundColor: AppColors.primary,
                        title: Text(
                          'Urutkan Berdasarkan',
                          style: TextStyle(color: AppColors.putih),
                        ),
                        content: StatefulBuilder(
                          builder: (context, setState) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<String>(
                                value: 'terbaru',
                                groupValue: selected,
                                onChanged: (v) => setState(() => selected = v!),
                                title: Text(
                                  'Terbaru',
                                  style: TextStyle(color: AppColors.putih),
                                ),
                                activeColor: AppColors.putih,
                              ),
                              RadioListTile<String>(
                                value: 'terlama',
                                groupValue: selected,
                                onChanged: (v) => setState(() => selected = v!),
                                title: Text(
                                  'Terlama',
                                  style: TextStyle(color: AppColors.putih),
                                ),
                                activeColor: AppColors.putih,
                              ),
                              RadioListTile<String>(
                                value: 'nama',
                                groupValue: selected,
                                onChanged: (v) => setState(() => selected = v!),
                                title: Text(
                                  'Per-orang',
                                  style: TextStyle(color: AppColors.putih),
                                ),
                                activeColor: AppColors.putih,
                              ),
                              RadioListTile<String>(
                                value: 'status',
                                groupValue: selected,
                                onChanged: (v) => setState(() => selected = v!),
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
                                  child: const Text('Batal'),
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Terapkan'),
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
                              context.isIndonesian
                                  ? 'Belum ada tugas'
                                  : 'No task available',
                              style: TextStyle(
                                color: AppColors.putih,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.isIndonesian
                                  ? 'Tap tombol + untuk menambah tugas baru'
                                  : 'Press + to add new task',
                              style: TextStyle(
                                color: AppColors.putih.withOpacity(0.7),
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
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 16.0,
                      left: 16.0,
                    ),
                    child: TugasTabelWeb(
                      tugasList: displayedList,
                      onActionDone: () {
                        searchController.clear();
                      },
                    ),
                  );
                  // } else {
                  //   return FeatureGuard(
                  //     featureId: "user_tabel_task",
                  //     child: TugasUserTabel(
                  //       tugasList: displayedList,
                  //       onActionDone: () {
                  //         searchController.clear();
                  //       },
                  //     ),
                  //   );
                  // }
                },
              ),
            ],
          ),
          // Floating Action Button
          FeatureGuard(
            requiredFeature: "tambah_tugas",
            child: Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, AppRoutes.tugasForm);
                  // Kalau ada update, refresh otomatis
                  if (result == true) {
                    tugasProvider.fetchTugas();
                  }
                  searchController.clear();
                },
                backgroundColor: AppColors.secondary,
                elevation: 8,
                shape: const CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.plus,
                    color: AppColors.putih,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

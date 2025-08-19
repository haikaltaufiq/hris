import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/tugas/tugas_form/tugas_form.dart';
import 'package:hr/presentation/pages/tugas/widgets/tugas_tabel.dart';
import 'package:hr/provider/function/tugas_provider.dart';
import 'package:provider/provider.dart';

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TugasProvider>().fetchTugas();
    });
  }

  Future<void> _refreshData() async {
    await context.read<TugasProvider>().fetchTugas();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tugasProvider = context.watch<TugasProvider>();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Header(title: 'Manajemen Tugas'),
              SearchingBar(
                controller: searchController,
                onChanged: (value) {
                  tugasProvider.filterTugas(value);
                },
                onFilter1Tap: () => print("Filter1 Halaman A"),
              ),
              // Use Consumer to watch TugasProvider state
              Consumer<TugasProvider>(
                builder: (context, tugasProvider, child) {
                  final displayedList = searchController.text.isEmpty
                      ? tugasProvider.tugasList
                      : tugasProvider.filteredTugasList;
                  if (tugasProvider.isLoading) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: LoadingWidget(),
                      ),
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
                                fontFamily: GoogleFonts.poppins().fontFamily,
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
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (displayedList.isEmpty) {
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
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap tombol + untuk menambah tugas baru',
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
                    );
                  }

                  // Show the table with data
                  return TugasTabel(
                    tugasList: displayedList,
                    onActionDone: () {
                      searchController.clear();
                    },
                  );
                },
              ),
            ],
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
              if (result == true) {
                // Refresh data after successful creation
                _refreshData();
              }
            },
            backgroundColor: AppColors.secondary,
            shape: const CircleBorder(),
            child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
          ),
        ),
      ],
    );
  }
}

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/custom/sorting.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/karyawan/karyawan_form/karyawan_form.dart';
import 'package:hr/features/karyawan/widgets/karyawan_tabel.dart';
import 'package:provider/provider.dart';

class KaryawanMobile extends StatefulWidget {
  const KaryawanMobile({super.key});

  @override
  State<KaryawanMobile> createState() => _KaryawanMobileState();
}

class _KaryawanMobileState extends State<KaryawanMobile> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto load data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserProvider>();
      provider.loadCacheFirst(); // Load cache first
      provider.fetchUsers(); // Then fetch from API
    });
  }

  Future<void> _refreshData() async {
    await context.read<UserProvider>().fetchUsers(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isLoading = userProvider.isLoading;
        final errorMessage = userProvider.errorMessage;
        final users = searchController.text.isEmpty
            ? userProvider.users
            : userProvider.filteredUsers;
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView(
                    children: [
                      Header(
                          title: context.isIndonesian
                              ? 'Manajemen Karyawan'
                              : 'Employee Management'),
                      SearchingBar(
                        controller: searchController,
                        onChanged: (value) {
                          userProvider.searchUsers(value);
                          // Bisa nanti filter users list di provider kalau mau
                        },
                        onFilter1Tap: () async {
                          final provider = context.read<UserProvider>();

                          final selected = await showSortDialog(
                            context: context,
                            title: context.isIndonesian
                                ? 'Urutkan Berdasarkan'
                                : 'Sort By',
                            currentValue: provider.currentSortField,
                            options: [
                              {
                                'value': 'terbaru',
                                'label':
                                    context.isIndonesian ? 'Terbaru' : 'Newest'
                              },
                              {
                                'value': 'terlama',
                                'label':
                                    context.isIndonesian ? 'Terlama' : 'Oldest'
                              },
                              {
                                'value': 'departemen',
                                'label': context.isIndonesian
                                    ? 'Departemen'
                                    : 'Department'
                              },
                              {'value': 'peran', 'label': 'Peran'},
                            ],
                          );

                          if (selected != null) {
                            provider.sortUsers(selected);
                          }
                        },
                      ),
                      if (isLoading && users.isEmpty)
                        Center(
                          child: LoadingWidget(),
                        )
                      else if (errorMessage != null)
                        Center(child: Text(errorMessage))
                      else if (users.isEmpty && !isLoading)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 64,
                                  color: AppColors.putih.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.isIndonesian
                                      ? 'Belum ada Karyawan'
                                      : 'No Employee available',
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
                                  context.isIndonesian
                                      ? 'Tap tombol + untuk menambah karyawan baru'
                                      : 'Press + button to add new employee',
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
                        )
                      else
                        KaryawanTabel(
                          users: users,
                          onActionDone: _refreshData,
                        )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const KaryawanForm(),
                        ),
                      );

                      // Kalau ada update, refresh otomatis
                      if (result == true) {
                        userProvider.fetchUsers();
                      }
                    },
                    backgroundColor: AppColors.secondary,
                    shape: const CircleBorder(),
                    child:
                        FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

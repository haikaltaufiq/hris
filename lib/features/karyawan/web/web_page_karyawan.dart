import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/custom/sorting.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/karyawan/web/web_tabel_karyawan.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class WebPageKaryawan extends StatefulWidget {
  const WebPageKaryawan({super.key});

  @override
  State<WebPageKaryawan> createState() => _WebPageKaryawanState();
}

class _WebPageKaryawanState extends State<WebPageKaryawan> {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      final isLoading = userProvider.isLoading;
      final users = searchController.text.isEmpty
          ? userProvider.users
          : userProvider.filteredUsers;
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
                    userProvider.searchUsers(value);
                    // Bisa nanti filter users list di provider kalau mau
                  },
                  onFilter1Tap: () async {
                    final provider = context.read<UserProvider>();

                    final selected = await showSortDialog(
                      context: context,
                      title: 'Urutkan User Berdasarkan',
                      currentValue: provider.currentSortField,
                      options: [
                        {'value': 'terbaru', 'label': 'Terbaru'},
                        {'value': 'terlama', 'label': 'Terlama'},
                        {'value': 'departemen', 'label': 'Departemen'},
                        {'value': 'peran', 'label': 'Peran'},
                      ],
                    );

                    if (selected != null) {
                      provider.sortUsers(selected);
                    }
                  },
                ),
                if (isLoading)
                  Center(
                    child: LoadingWidget(),
                  )
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
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.isIndonesian
                                ? 'Tap tombol + untuk menambah karyawan baru'
                                : 'Press + Button to add new employee',
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
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: KaryawanTabelWeb(users: users),
                  )
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                      context, AppRoutes.karyawanForm);

                  // Kalau ada update, refresh otomatis
                  if (result == true) {
                    userProvider.fetchUsers();
                  }
                  searchController.clear();
                },
                backgroundColor: AppColors.secondary,
                shape: const CircleBorder(),
                child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
              ),
            ),
          ],
        ),
      );
    });
  }
}

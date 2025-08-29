import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
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
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      final isLoading = userProvider.isLoading;
      final errorMessage = userProvider.errorMessage;
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
                  onFilter1Tap: () => print("Filter1 Halaman A"),
                ),
                if (isLoading)
                  Center(
                    child: LoadingWidget(),
                  )
                else if (errorMessage != null)
                  Center(child: Text(errorMessage))
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

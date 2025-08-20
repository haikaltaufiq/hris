// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/provider/function/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/karyawan/karyawan_form/karyawan_form.dart';
import 'package:hr/presentation/pages/karyawan/widgets/karyawan_tabel.dart';

class KaryawanPage extends StatefulWidget {
  const KaryawanPage({super.key});

  @override
  State<KaryawanPage> createState() => _KaryawanPageState();
}

class _KaryawanPageState extends State<KaryawanPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto load data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  Future<void> _refreshData() async {
    await context.read<UserProvider>().fetchUsers();
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
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Header(title: 'Manajemen Karyawan'),
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
                    KaryawanTabel(users: users),
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
                child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
              ),
            ),
          ],
        );
      },
    );
  }
}

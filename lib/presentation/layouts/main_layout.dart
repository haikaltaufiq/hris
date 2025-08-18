import 'package:flutter/material.dart';
import 'package:hr/components/navigation/navbar.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/departemen/departemen_page.dart';
import 'package:hr/presentation/pages/gaji/gaji_page.dart';
import 'package:hr/presentation/pages/jabatan/jabatan_page.dart';
import 'package:hr/presentation/pages/karyawan/karyawan_page.dart';
import 'package:hr/presentation/pages/log_aktivitas/log_page.dart';
import 'package:hr/presentation/pages/pengaturan/pengaturan_page.dart';
import 'package:hr/presentation/pages/peran_akses/peran_akses_page.dart';
import 'package:hr/presentation/pages/tentang/tentang_page.dart';
import 'package:hr/presentation/pages/absen/absen_page.dart';
import 'package:hr/presentation/pages/cuti/cuti_page.dart';
import 'package:hr/presentation/pages/dashboard/dashboard_page.dart';
import 'package:hr/presentation/pages/lembur/lembur_page.dart';
import 'package:hr/presentation/pages/profile/profile_page.dart';
import 'package:hr/presentation/pages/tugas/tugas_page.dart';

class MainLayout extends StatefulWidget {
  final int? initialIndex;
  final int? externalPageIndex;

  const MainLayout({
    super.key,
    this.initialIndex,
    this.externalPageIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex = 0;
  bool isDarkMode = AppColors.isDarkMode;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      AppColors.isDarkMode = isDarkMode; // update warna global jika ada
    });
  }

  final List<Widget> _pages = const [
    DashboardPage(),
    AbsenPage(),
    TugasPage(),
    LemburPage(),
    CutiPage(),
  ];

  List<Widget> get _externalPages {
    return [
      const KaryawanPage(),
      const GajiPage(),
      const DepartemenPage(),
      const JabatanPage(),
      const PeranAksesPage(),
      const TentangPage(),
      const LogPage(),
      PengaturanPage(
        isDarkMode: isDarkMode,
        toggleTheme: toggleTheme,
      ),
      const ProfilePage(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
    isDarkMode = AppColors.isDarkMode;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isExternal = widget.externalPageIndex != null;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: isExternal
            ? _externalPages[widget.externalPageIndex!]
            : _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (int index) {
          if (isExternal) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainLayout(initialIndex: index),
              ),
            );
          } else {
            _onItemTapped(index);
          }
        },
      ),
    );
  }
}

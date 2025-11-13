// ignore_for_file: await_only_futures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/auth_service.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/department/view_model/department_viewmodels.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/data/services/fcm_service.dart';
import 'package:hr/layout/main_layout.dart';
import 'package:hr/main.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({
    super.key,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader>
    with SingleTickerProviderStateMixin {
  late BuildContext rootContext; // simpan context utama
  bool _showDropdown = false;
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;
  static String? cachedNama;
  static String? cachedPeran;
  String _nama = "";
  String _peran = "";

  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _loadCachedUser();
    _preloadProviders();
  }

  void _loadCachedUser() async {
    if (cachedNama != null && cachedPeran != null) {
      // langsung pakai cache tanpa delay
      _nama = cachedNama!;
      _peran = cachedPeran!;
      setState(() {});
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('nama') ?? '';
    final peran = prefs.getString('peran') ?? '';

    cachedNama = nama;
    cachedPeran = peran;

    if (mounted) {
      setState(() {
        _nama = nama;
        _peran = peran;
      });
    }
  }

  static void clearUserCache() {
    cachedNama = null;
    cachedPeran = null;
  }

  Future<void> _preloadProviders() async {
    await Future.microtask(() {
      context.read<AbsenProvider>().fetchAbsensi();
      context.read<TugasProvider>().fetchTugas();
      context.read<UserProvider>().fetchUsers();
      context.read<DepartmentViewModel>().fetchDepartemen();
    });
  }

  void _toggleDropdown() {
    if (_showDropdown) {
      _hideDropdown();
    } else {
      _showDropdownMenu();
    }
  }

  void _showDropdownMenu() {
    if (_dropdownOverlay != null) return; // jangan insert 2x

    final RenderBox? renderBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: offset.dy + renderBox.size.height + 8, // sedikit lebih jauh
            right: MediaQuery.of(context).size.width * 0.02,
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SizeTransition(
                  sizeFactor: _sizeAnimation,
                  axisAlignment: -1.0,
                  child: Container(
                    width: 180, // lebih lebar
                    decoration: BoxDecoration(
                      color: AppColors.secondary, // ganti ke putih
                      borderRadius:
                          BorderRadius.circular(12), // corner lebih rounded
                      boxShadow: [
                        // Shadow yang lebih bagus
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8), // padding vertikal
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDropdownItem(
                              context.isIndonesian ? "Profile" : "Profil",
                              Icons.person_outline, () {
                            _hideDropdownImmediate();
                            Navigator.pushNamed(context, AppRoutes.profile);
                          }),
                          // Divider
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          _buildDropdownItem(
                              context.isIndonesian ? "Pengaturan" : "Settings",
                              Icons.settings_outlined, () {
                            _hideDropdownImmediate();
                            Navigator.pushNamed(context, AppRoutes.pengaturan);
                          }),
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          _buildDropdownItem(
                            context.isIndonesian ? "Keluar" : "Logout",
                            Icons.logout,
                            () async {
                              _hideDropdownImmediate();

                              final confirmed = await showConfirmationDialog(
                                navigatorKey.currentContext!,
                                title: context.isIndonesian
                                    ? "Konfirmasi Logout"
                                    : "Logout Confirmation",
                                content: context.isIndonesian
                                    ? "Apakah Anda yakin ingin keluar dari akun ini?"
                                    : "Are you sure you want to log out of this account?",
                                confirmText:
                                    context.isIndonesian ? "Keluar" : "Logout",
                                cancelText:
                                    context.isIndonesian ? "Batal" : "Cancel",
                                confirmColor: AppColors.red,
                              );

                              if (!confirmed) return;

                              // 🔑 Logout sequence: await dulu semua
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              final userId = prefs.getInt('user_id');

                              if (userId != null) {
                                await FcmService.deleteLocalToken();
                              }

                              if (token != null) {
                                await AuthService().logout();
                              }

                              clearUserCache();
                              if (MainLayout.onClearFeatureCache != null) {
                                await MainLayout.onClearFeatureCache!.call();
                              }

                              await prefs.clear();

                              // 🔑 Setelah semua selesai, baru navigasi
                              navigatorKey.currentState!
                                  .pushNamedAndRemoveUntil(
                                context.isNativeMobile
                                    ? AppRoutes.landingPageMobile
                                    : AppRoutes.login,
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    _controller.forward(from: 0);
    setState(() {
      _showDropdown = true;
    });
  }

  // Method untuk hide dropdown dengan animasi
  void _hideDropdown() {
    if (_dropdownOverlay == null || !_showDropdown) return;

    // Set state first to prevent multiple calls
    setState(() {
      _showDropdown = false;
    });

    // Use addPostFrameCallback to ensure animation completes properly on web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.reverse().then((_) {
        _removeOverlay();
      }).catchError((error) {
        // Fallback jika animasi gagal
        _removeOverlay();
      });
    });
  }

  // Method untuk hide dropdown tanpa animasi (untuk navigasi)
  void _hideDropdownImmediate() {
    if (_dropdownOverlay == null) return;

    setState(() {
      _showDropdown = false;
    });

    _removeOverlay();
  }

  void _removeOverlay() {
    if (_dropdownOverlay != null) {
      _dropdownOverlay!.remove();
      _dropdownOverlay = null;
    }
  }

  Widget _buildDropdownItem(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.putih),
      title: Text(
        text,
        style: TextStyle(
          color: AppColors.putih,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    rootContext = context; // biar gak klik 2 kali logout

    // Clean up overlay when dependencies change
    if (_dropdownOverlay != null) {
      _removeOverlay();
      setState(() {
        _showDropdown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                      color: AppColors.putih.withOpacity(0.4), width: 2),
                ),
                child: ClipOval(
                  child: _nama.isNotEmpty
                      ? Center(
                          child: Text(
                            _nama.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.putih,
                            ),
                          ),
                        )
                      : Icon(
                          FontAwesomeIcons.user,
                          size: 50,
                          color: AppColors.putih,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nama.split(" ").take(2).join(" "),
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.bold,
                    color: AppColors.putih,
                  ),
                ),
                Text(
                  _peran,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    height: 0.8,
                    fontWeight: FontWeight.w400,
                    color: AppColors.putih.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          key: _menuKey,
          onTap: _toggleDropdown,
          child: FaIcon(
            FontAwesomeIcons.barsStaggered,
            color: AppColors.putih,
            size: 25,
          ),
        ),
      ],
    );
  }
}

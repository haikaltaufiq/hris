import 'package:flutter/material.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/navbar.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/auth_service.dart';
import 'package:hr/data/services/fcm_service.dart';
import 'package:hr/main.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  static Future<void> Function()? onClearFeatureCache;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  bool isCollapsed = false;
  bool _showDropdown = false;
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;
  List<String> _userFitur = [];

  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;
  static List<String>? _cachedFitur;
  // Map route ke index

  Future<void> logoutUser() async {
    await FeatureAccess.clear();
    _cachedFitur = null;
    _userFitur = [];
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('token');

    if (userId != null) {
      await FcmService.deleteLocalToken();
    }
    if (token != null) {
      await AuthService().logout();
    }
    await prefs.clear();

    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  static const Map<String, int> _routeToIndex = {
    AppRoutes.dashboard: 0,
    AppRoutes.dashboardMobile: 0,
    AppRoutes.attendance: 1,
    AppRoutes.task: 2,
    AppRoutes.overTime: 3,
    AppRoutes.leave: 4,
    AppRoutes.employee: 5,
    AppRoutes.payroll: 6,
    AppRoutes.department: 7,
    AppRoutes.jabatan: 8,
    AppRoutes.peran: 9,
    AppRoutes.potonganGaji: 10,
    AppRoutes.logActivity: 11,
    AppRoutes.reminder: 12,
    AppRoutes.pengaturan: 13,
    AppRoutes.infoKantor: 14,
    AppRoutes.danger: 15,
    AppRoutes.resetDevice: 16,
    AppRoutes.bukaAkun: 17,
    AppRoutes.mapPage: 18,
    AppRoutes.potonganForm: 19,
    AppRoutes.potonganEdit: 20,
    AppRoutes.info: 21,
    AppRoutes.taskEdit: 22,
    AppRoutes.reminderAdd: 23,
    AppRoutes.reminderEdit: 24,
    AppRoutes.peranForm: 25,
    AppRoutes.tugasForm: 26,
    AppRoutes.karyawanForm: 27,
    AppRoutes.checkin: 28,
    AppRoutes.checkout: 29,
    AppRoutes.cutiForm: 30,
    AppRoutes.lemburForm: 31,
    AppRoutes.locationTrack: 32,
    AppRoutes.detailAbsen: 33,
  };

  // Map index ke route
  static const List<String> _indexToRoute = [
    AppRoutes.dashboard,
    AppRoutes.attendance,
    AppRoutes.task,
    AppRoutes.overTime,
    AppRoutes.leave,
    AppRoutes.employee,
    AppRoutes.payroll,
    AppRoutes.department,
    AppRoutes.jabatan,
    AppRoutes.peran,
    AppRoutes.potonganGaji,
    AppRoutes.logActivity,
    AppRoutes.reminder,
    AppRoutes.pengaturan,
    AppRoutes.infoKantor,
    AppRoutes.danger,
    AppRoutes.resetDevice,
    AppRoutes.bukaAkun,
    AppRoutes.mapPage,
    AppRoutes.potonganForm,
    AppRoutes.potonganEdit,
    AppRoutes.info,
    AppRoutes.taskEdit,
    AppRoutes.reminderAdd,
    AppRoutes.reminderEdit,
    AppRoutes.peranForm,
    AppRoutes.tugasForm,
    AppRoutes.karyawanForm,
    AppRoutes.checkin,
    AppRoutes.checkout,
    AppRoutes.cutiForm,
    AppRoutes.lemburForm,
    AppRoutes.locationTrack,
    AppRoutes.detailAbsen,
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = _routeToIndex[widget.currentRoute] ?? 0;
    MainLayout.onClearFeatureCache = clearFeatureCache;

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

    // 🔹 kalau udah pernah cache fitur, pakai langsung
    if (_cachedFitur != null && _cachedFitur!.isNotEmpty) {
      _userFitur = _cachedFitur!;
    } else {
      _loadFiturOnce();
    }
  }

  // ambil fitur dari shared preferences
  Future<void> _loadFiturOnce() async {
    await FeatureAccess.init();
    final fiturList = FeatureAccess.fitur;

    _cachedFitur = fiturList; // simpan cache global biar gak reload tiap route
    if (mounted) {
      setState(() {
        _userFitur = fiturList;
      });
    }
  }

  Future<void> clearFeatureCache() async {
    await FeatureAccess.clear();
    setState(() {
      _cachedFitur = null;
      _userFitur = [];
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
                              context.isIndonesian ? "Profil" : "Profile",
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

                              // Langsung navigate dulu biar responsif
                              navigatorKey.currentState!
                                  .pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => false,
                              );

                              // Jalankan cleanup di background
                              Future.microtask(() async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                final userId = prefs.getInt('user_id');
                                final token = prefs.getString('token');

                                if (userId != null) {
                                  await FcmService.deleteLocalToken();
                                }

                                if (token != null) {
                                  await AuthService().logout();
                                }

                                await FeatureAccess.clear();
                                _cachedFitur = null;
                                _userFitur = [];

                                await prefs.clear();
                              });
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

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      selectedIndex = _routeToIndex[widget.currentRoute] ?? 0;
    }
  }

  Widget _buildDropdownItem(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.putih,
        size: 20,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: AppColors.putih,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    MainLayout.onClearFeatureCache = null;

    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clean up overlay when dependencies change
    if (_dropdownOverlay != null) {
      _removeOverlay();
      setState(() {
        _showDropdown = false;
      });
    }
  }

  void _onNavItemTapped(int index) {
    if (index != selectedIndex && index < _indexToRoute.length) {
      final route = _indexToRoute[index];

      // ⭐ SOLUSI 1: Gunakan pushNamed alih-alih pushReplacementNamed
      // Ini akan menjaga widget tree dari rebuild
      Navigator.pushNamed(context, route);

      setState(() {
        selectedIndex = index;
      });
    }
  }

  void _toggleSidebar() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      bottomNavigationBar: context.isMobile
          ? ResponsiveNavBar(
              selectedIndex: selectedIndex,
              onItemTapped: _onNavItemTapped,
              userFitur: _userFitur,
            )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        Row(
          children: [
            //sidebar
            RepaintBoundary(
              child: ResponsiveNavBar(
                selectedIndex: selectedIndex,
                onItemTapped: _onNavItemTapped,
                isCollapsed: isCollapsed,
                userFitur: _userFitur,
                onLogout: () async {
                  // 🔥 inilah yang sinkron sama state MainLayout
                  await FeatureAccess.clear();
                  setState(() {
                    _cachedFitur = null;
                    _userFitur = [];
                  });

                  final prefs = await SharedPreferences.getInstance();
                  final userId =
                      prefs.getInt('user_id'); // simpan dulu sebelum dihapus
                  final token = prefs.getString('token');

                  // hapus token FCM loakl
                  if (userId != null) {
                    await FcmService.deleteLocalToken;
                  }

                  // panggil API logout auth
                  if (token != null) {
                    await AuthService().logout();
                    // debugPrint("Logout result: $result");
                  }
                  // baru bersihkan data lokal
                  await prefs.clear();

                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
              ),
            ),
            //main content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 60), // tinggi AppBar
                color: AppColors.latar3,
                child: widget.child,
              ),
            ),
          ],
        ),
        Positioned(
          left: 0, // sesuai width sidebar
          right: 0,
          top: 0,
          height: 60,
          child: _buildDesktopAppBar(),
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar() {
    final isFormPage = [
      AppRoutes.tugasForm,
      AppRoutes.karyawanForm,
      AppRoutes.potonganForm,
      AppRoutes.potonganEdit,
      AppRoutes.taskEdit,
      AppRoutes.reminderAdd,
      AppRoutes.reminderEdit,
      AppRoutes.peranForm,
      AppRoutes.checkin,
      AppRoutes.checkout,
      AppRoutes.cutiForm,
      AppRoutes.lemburForm,
      AppRoutes.karyawanEditForm,
      AppRoutes.info,
    ].contains(widget.currentRoute);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            if (!isFormPage)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleSidebar,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isCollapsed ? Icons.menu : Icons.menu_open,
                      color: AppColors.putih,
                      size: 25,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 16),

            // tombol back kalau di form page
            if (isFormPage) ...[
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios, color: AppColors.putih),
              ),
              const SizedBox(width: 8),
            ],
            SizedBox(
              width: 25,
            ),
            Expanded(
              child: Text(
                _getPageTitle(),
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildUserActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActions() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: _menuKey,
            onTap: _toggleDropdown,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.person,
                  color: AppColors.putih,
                  size: 25,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPageTitle() {
    switch (widget.currentRoute) {
      case AppRoutes.dashboard:
      case AppRoutes.dashboardMobile:
        return 'Dashboard';
      case AppRoutes.attendance:
        return context.isIndonesian ? 'Kehadiran' : 'Attendance';
      case AppRoutes.task:
        return context.isIndonesian ? 'Manajemen Tugas' : 'Task Management';
      case AppRoutes.overTime:
        return context.isIndonesian ? 'Lembur' : 'Over Time';
      case AppRoutes.leave:
        return context.isIndonesian ? 'Pengajuan Cuti' : 'Leave Proposal';
      case AppRoutes.employee:
        return context.isIndonesian
            ? 'Manajemen Karyawan'
            : 'Employee Management';
      case AppRoutes.payroll:
        return context.isIndonesian ? 'Penggajian' : 'Payroll';
      case AppRoutes.department:
        return context.isIndonesian ? 'Departemen' : 'Department';
      case AppRoutes.jabatan:
        return context.isIndonesian ? 'Jabatan' : 'Position';
      case AppRoutes.peran:
        return context.isIndonesian ? 'Manajemen Akses' : 'Management Access';
      case AppRoutes.potonganGaji:
        return context.isIndonesian ? 'Potongan Gaji' : 'Salary Deduction';
      case AppRoutes.info:
        return context.isIndonesian
            ? 'Informasi Perusahaan'
            : 'Company Information';
      case AppRoutes.pengaturan:
        return context.isIndonesian ? 'Pengaturan' : 'Settings';
      case AppRoutes.logActivity:
        return context.isIndonesian ? 'Log Aktivitas' : 'Log Activity';
      case AppRoutes.profile:
        return context.isIndonesian ? 'Profil' : 'Profile';
      case AppRoutes.tugasForm:
        return context.isIndonesian ? 'Tambah Tugas' : 'Add Task';
      case AppRoutes.karyawanForm:
        return context.isIndonesian ? 'Tambah Karyawan' : 'Add Employee';
      case AppRoutes.mapPage:
        return context.isIndonesian ? 'Lihat Lokasi' : 'See Location';
      case AppRoutes.potonganForm:
        return context.isIndonesian ? 'Form Potongan' : 'Potongan Form';
      case AppRoutes.potonganEdit:
        return context.isIndonesian ? 'Edit Potongan' : 'Potongan Edit';
      case AppRoutes.reminder:
        return context.isIndonesian ? 'Pengingat' : 'Reminder Page';
      case AppRoutes.taskEdit:
        return context.isIndonesian ? 'Edit Tugas' : 'Edit Task';
      case AppRoutes.reminderAdd:
        return context.isIndonesian ? 'Tambah Pengingat' : 'Add Reminder';
      case AppRoutes.reminderEdit:
        return context.isIndonesian ? 'Edit Pengingat' : 'Edit Reminder';
      case AppRoutes.peranForm:
        return context.isIndonesian ? 'Form Peran' : 'Peran Form';
      case AppRoutes.infoKantor:
        return context.isIndonesian ? 'Info Kantor' : 'Info Kantor';
      case AppRoutes.danger:
        return context.isIndonesian ? 'Reset Data' : 'Reset Data';
      case AppRoutes.checkin:
        return context.isIndonesian ? 'Absen Masuk' : 'Check-in';
      case AppRoutes.checkout:
        return context.isIndonesian ? 'Absen Keluar' : 'Check-out';
      case AppRoutes.cutiForm:
        return context.isIndonesian ? 'Pengajuan Cuti' : 'Leave Form';
      case AppRoutes.lemburForm:
        return context.isIndonesian ? 'Pengajuan Lembur' : 'Overtime Form';
      case AppRoutes.resetDevice:
        return context.isIndonesian ? 'Reset Perangkat' : 'Reset Device';
      case AppRoutes.bukaAkun:
        return context.isIndonesian ? 'Buka Akun' : 'Open Account';
      case AppRoutes.locationTrack:
        return context.isIndonesian ? 'Pantau Lokasi' : 'Location Tracking';
      case AppRoutes.detailAbsen:
        return '';
      default:
        return 'HRIS System';
    }
  }
}

extension MainLayoutExtension on Widget {
  Widget withMainLayout(String currentRoute) {
    return MainLayout(
      currentRoute: currentRoute,
      child: this,
    );
  }
}

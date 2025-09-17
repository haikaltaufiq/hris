import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/navbar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/auth/login_page.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

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
    AppRoutes.mapPage: 16,
    AppRoutes.potonganForm: 17,
    AppRoutes.potonganEdit: 18,
    AppRoutes.info: 19,
    AppRoutes.taskEdit: 20,
    AppRoutes.reminderAdd: 21,
    AppRoutes.reminderEdit: 22,
    AppRoutes.peranForm: 23,
    AppRoutes.tugasForm: 24,
    AppRoutes.karyawanForm: 25,
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
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = _routeToIndex[widget.currentRoute] ?? 0;

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

    if (_cachedFitur != null) {
      _userFitur = _cachedFitur!;
    } else {
      _loadFitur();
    }
  }

  // ambil fitur dari shared preferences
  Future<void> _loadFitur() async {
    final prefs = await SharedPreferences.getInstance();
    final fiturString = prefs.getString('fitur');
    if (fiturString != null) {
      final List<dynamic> decoded = jsonDecode(fiturString);
      _cachedFitur = decoded.map((f) => f['nama_fitur'].toString()).toList();
      if (mounted) {
        setState(() {
          _userFitur = _cachedFitur!;
        });
      }
    }
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
                          _buildDropdownItem("Profile", Icons.person_outline,
                              () {
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
                              "Settings", Icons.settings_outlined, () {
                            _hideDropdownImmediate();
                            Navigator.pushNamed(context, AppRoutes.pengaturan);
                          }),
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          _buildDropdownItem(
                            "Logout",
                            Icons.logout,
                            () async {
                              _hideDropdownImmediate();
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs
                                  .clear(); // hapus semua, termasuk token & fitur

                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginPage()),
                                  (route) => false,
                                );
                              }
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
              ),
            ),
            //main content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 70), // tinggi AppBar
                color: const Color(0xFF0A0A0A),
                child: widget.child,
              ),
            ),
          ],
        ),
        Positioned(
          left: 0, // sesuai width sidebar
          right: 0,
          top: 0,
          height: 70,
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
    ].contains(widget.currentRoute);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
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
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: FaIcon(
                FontAwesomeIcons.bell,
                color: AppColors.putih,
                size: 25,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
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
        return 'Attendance';
      case AppRoutes.task:
        return 'Task Management';
      case AppRoutes.overTime:
        return 'Over Time';
      case AppRoutes.leave:
        return 'Leave Proposal';
      case AppRoutes.employee:
        return 'Employee Management';
      case AppRoutes.payroll:
        return 'Payroll';
      case AppRoutes.department:
        return 'Department';
      case AppRoutes.jabatan:
        return 'Position';
      case AppRoutes.peran:
        return 'Management Access';
      case AppRoutes.potonganGaji:
        return 'Salary Deduction';
      case AppRoutes.info:
        return 'Company Information';
      case AppRoutes.pengaturan:
        return 'Settings';
      case AppRoutes.logActivity:
        return 'Log Activity';
      case AppRoutes.profile:
        return 'Profile';
      case AppRoutes.tugasForm:
        return 'Add Task';
      case AppRoutes.karyawanForm:
        return 'Add Employee';
      case AppRoutes.mapPage:
        return 'See Location';
      case AppRoutes.potonganForm:
        return 'Potongan Form';
      case AppRoutes.potonganEdit:
        return 'Potongan Edit';
      case AppRoutes.reminder:
        return 'Reminder Page';
      case AppRoutes.taskEdit:
        return 'Edit Task';
      case AppRoutes.reminderAdd:
        return 'Add Reminder';
      case AppRoutes.reminderEdit:
        return 'Edit Reminder';
      case AppRoutes.peranForm:
        return 'Peran Form';
      case AppRoutes.infoKantor:
        return 'Info Kantor';
      case AppRoutes.danger:
        return 'Danger Zone';
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

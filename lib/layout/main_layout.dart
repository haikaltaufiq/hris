import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/navbar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
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

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  bool isCollapsed = false;

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
    AppRoutes.info: 11,
    AppRoutes.logActivity: 12,
    AppRoutes.pengaturan: 13,
    AppRoutes.tugasForm: 14,
    AppRoutes.karyawanForm: 15,
    AppRoutes.mapPage: 16,
    AppRoutes.potonganForm: 17,
    AppRoutes.potonganEdit: 18,
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
    AppRoutes.info,
    AppRoutes.logActivity,
    AppRoutes.pengaturan,
    AppRoutes.tugasForm,
    AppRoutes.karyawanForm,
    AppRoutes.mapPage,
    AppRoutes.potonganForm,
    AppRoutes.potonganEdit,
  ];
  String _nama = '';

  @override
  void initState() {
    super.initState();
    selectedIndex = _routeToIndex[widget.currentRoute] ?? 0;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? '';
    });
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      selectedIndex = _routeToIndex[widget.currentRoute] ?? 0;
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
    return Row(
      children: [
        // ⭐ SOLUSI 2: Wrap navbar dengan RepaintBoundary untuk optimasi
        RepaintBoundary(
          child: ResponsiveNavBar(
            selectedIndex: selectedIndex,
            onItemTapped: _onNavItemTapped,
            isCollapsed: isCollapsed,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildDesktopAppBar(),
              Expanded(
                child: Container(
                  color: const Color(0xFF0A0A0A),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.bg,
            AppColors.primary,
          ],
        ),
        border: const Border(
          bottom: BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
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
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
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
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
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
        return _nama.isNotEmpty ? 'Welcome $_nama' : 'Dashboard';
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

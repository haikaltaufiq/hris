import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/navbar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/routes/app_routes.dart';

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
    AppRoutes.logActivity: 11,
    AppRoutes.reminder: 12,
    AppRoutes.pengaturan: 13,
    AppRoutes.tugasForm: 14,
    AppRoutes.karyawanForm: 15,
    AppRoutes.mapPage: 16,
    AppRoutes.potonganForm: 17,
    AppRoutes.potonganEdit: 18,
    AppRoutes.info: 19,
    AppRoutes.taskEdit: 20,
    AppRoutes.reminderAdd: 21,
    AppRoutes.reminderEdit: 22,
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
    AppRoutes.tugasForm,
    AppRoutes.karyawanForm,
    AppRoutes.mapPage,
    AppRoutes.potonganForm,
    AppRoutes.potonganEdit,
    AppRoutes.info,
    AppRoutes.taskEdit,
    AppRoutes.reminderAdd,
    AppRoutes.reminderEdit,
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = _routeToIndex[widget.currentRoute] ?? 0;
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
    ].contains(widget.currentRoute);

    return Container(
      height: 70,
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

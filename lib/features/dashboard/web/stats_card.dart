import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/department/view_model/department_viewmodels.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebCard extends StatefulWidget {
  const WebCard({super.key});

  @override
  State<WebCard> createState() => _WebCardState();
}

class _WebCardState extends State<WebCard> with TickerProviderStateMixin {
  late AnimationController _animationController;

  static bool _cacheInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize cache first time
    if (!_cacheInitialized) {
      _loadUserDataToStaticCache();
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Load provider cache immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AbsenProvider>().loadCacheFirst();
        context.read<TugasProvider>().loadCacheFirst();
        context.read<UserProvider>().loadCacheFirst();
        context.read<DepartmentViewModel>().loadCacheFirst();
      }
    });

    _animationController.forward();
    _loadData();
  }

  void _loadUserDataToStaticCache() async {
    await SharedPreferences.getInstance();
    _cacheInitialized = true;
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    await Future.microtask(() {
      if (!mounted) return;
      context.read<AbsenProvider>().fetchAbsensi();
      context.read<TugasProvider>().fetchTugas();
      context.read<UserProvider>().fetchUsers();
      context.read<DepartmentViewModel>().fetchDepartemen();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 800;

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _statSection(),
                        const SizedBox(height: 10),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _statSection(),
                        const SizedBox(height: 10),
                      ],
                    );
            },
          ),
        );
      },
    );
  }

  Widget _statSection() {
    return Consumer3<UserProvider, DepartmentViewModel, TugasProvider>(
      builder: (context, userProv, deptProv, tugasProv, child) {
        final totalUser = userProv.totalUsers.toString();
        final totalDepartment = deptProv.totalDepartment.toString();
        final totalTask = tugasProv.totalTugas.toString();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: _statCard(
                title: context.isIndonesian
                    ? "Kehadiran Hari ini"
                    : "Today Attendance",
                value: totalDepartment,
                subtitle: context.isIndonesian
                    ? "Jumlah Pegawai Hadir Hari ini"
                    : "Today Employee Attendance",
                icon: FontAwesomeIcons.clipboardUser,
                iconColor: const Color.fromARGB(255, 88, 255, 54),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: _statCard(
                title: context.isIndonesian ? "Tugas Aktif" : "Active Tasks",
                value: totalTask,
                subtitle: context.isIndonesian
                    ? "Deadline minggu ini"
                    : "Due this week",
                icon: Icons.assignment_outlined,
                iconColor: const Color.fromARGB(255, 255, 80, 67),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: _statCard(
                title: context.isIndonesian ? "Departemen" : "Departments",
                value: totalDepartment,
                subtitle:
                    context.isIndonesian ? "Divisi Aktif" : "Active divisions",
                icon: FontAwesomeIcons.building,
                iconColor: const Color.fromARGB(255, 255, 128, 54),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: _statCard(
                title: context.isIndonesian ? "Total Pegawai" : "Employees",
                value: totalUser,
                subtitle: context.isIndonesian
                    ? "Jumlah Pegawai Keseluruhan"
                    : "Total Employees",
                icon: Icons.people_alt_rounded,
                iconColor: const Color.fromARGB(255, 82, 172, 246),
                isGrowth: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool isGrowth = false,
  }) {
    return _HoverCard(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Icon(icon, color: iconColor, size: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.putih.withOpacity(0.7),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppColors.putih.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _hovering
            ? (Matrix4.identity()..translate(0, -4, 0))
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}

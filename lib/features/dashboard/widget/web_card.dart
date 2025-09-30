import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
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

  String _nama = '';
  String _peran = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? '';
      _peran = prefs.getString('peran') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 800;

                return isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _welcomeCard(),
                          const SizedBox(height: 10),
                          _statSection(),
                          const SizedBox(height: 10),
                          _overviewCard(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Card
                          Flexible(
                            flex: 2,
                            child: _welcomeCard(),
                          ),
                          const SizedBox(width: 10),

                          // Stats
                          Flexible(
                            flex: 3,
                            child: _statSection(),
                          ),
                          const SizedBox(width: 10),

                          // Overview
                          Flexible(
                            flex: 2,
                            child: _overviewCard(),
                          ),
                        ],
                      );
              },
            ),
          );
        });
  }

  /// Bagian Stats Column biar rapih
  Widget _statSection() {
    final totalUser = context.read<UserProvider>().totalUsers.toString();
    final totalDepartment =
        context.read<DepartmentViewModel>().totalDepartment.toString();
    final totalTask = context.read<TugasProvider>().totalTugas.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statCard(
          title: "Departments",
          value: totalDepartment,
          subtitle: "Active divisions",
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 10),
        _statCard(
          title: "Employees",
          value: totalUser,
          subtitle: "Total Employees",
          icon: Icons.people_outline,
          isGrowth: true,
        ),
        const SizedBox(height: 10),
        _statCard(
          title: "Active Tasks",
          value: totalTask,
          subtitle: "Due this week",
          icon: Icons.assignment_outlined,
        ),
      ],
    );
  }

  /// Welcome Card dengan hover effect
  Widget _welcomeCard() {
    return _HoverCard(
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back,",
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _nama.split(" ").take(2).join(" "),
                  style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _peran,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 22,
            ),
            // Today's Cards Row
            Consumer3<AbsenProvider, UserProvider, TugasProvider>(
              builder: (context, absenProv, userProv, tugasProv, child) {
                final hadirHariIni = absenProv.todayJumlahHadir;
                final totalUser = userProv.totalUsers;

                final taskDeadline = tugasProv.todayActiveTask;
                final totalTask = tugasProv.totalTugas;

                return Row(
                  children: [
                    Expanded(
                      child: _todayCard(
                        title: "Today's Attendance",
                        value: "$hadirHariIni / $totalUser",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _todayCard(
                        title: "Today's Task Deadlines ",
                        value: "$taskDeadline / $totalTask",
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  /// Reusable Today Card dengan hover effect
  Widget _todayCard({required String title, required String value}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.2; // responsive height

    return _HoverCard(
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.putih,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // make value responsive with Flexible + FittedBox
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.6),
                    fontSize:
                        34, // tetap pake style asli, FittedBox yg nge-handle
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stat Card dengan hover effect
  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, color: AppColors.putih, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.putih.withOpacity(0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Overview Card dengan hover effect
  Widget _overviewCard() {
    return Consumer2<AbsenProvider, UserProvider>(
      builder: (context, absenProv, userProv, child) {
        final totalUser = userProv.totalUsers;
        final totalTugasSelesai =
            context.read<TugasProvider>().totalTugasSelesai.toDouble();
        final totalTugas = context.read<TugasProvider>().totalTugas.toDouble();
        // Hitung rate dengan aman
        final rate = (totalUser > 0)
            ? absenProv.jumlahHadir / totalUser // 0..1
            : 0.0;

        // Project completion 0..1
        final projectRate =
            (totalTugas > 0) ? totalTugasSelesai / totalTugas : 0.0;

        // Performance = 50% attendance + 50% project completion
        final performance = ((rate * 0.5) + (projectRate * 0.5));
        final overallProgress = (rate + projectRate + performance) / 3.0;
        return _HoverCard(
          child: Container(
            height: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monthly Overview",
                  style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                // Progress items
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _progress("Project Completion", projectRate,
                          const Color(0xFF4EDD53)),
                      const SizedBox(height: 16),
                      _progress("Attendance Rate", rate, Colors.orange),
                      const SizedBox(height: 16),
                      _progress("Performance Score", performance,
                          const Color.fromARGB(255, 62, 168, 255)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Footer card
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overall",
                            style: TextStyle(
                              color: AppColors.putih.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${(overallProgress * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: AppColors.putih,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[400],
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _progress(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.putih.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${(progress * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                color: AppColors.putih,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: AppColors.putih.withOpacity(0.1),
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}

/// Widget untuk menangani hover effect dengan animasi subtle
class _HoverCard extends StatefulWidget {
  final Widget child;

  const _HoverCard({
    required this.child,
  });

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
            ? (Matrix4.identity()..translate(0, -4, 0)) // Naik 4px saat hover
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}

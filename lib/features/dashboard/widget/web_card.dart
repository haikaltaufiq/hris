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

  static String _cachedNama = '';
  static String _cachedPeran = '';
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
    final prefs = await SharedPreferences.getInstance();
    _cachedNama = prefs.getString('nama') ?? '';
    _cachedPeran = prefs.getString('peran') ?? '';
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
                        _welcomeCard(),
                        const SizedBox(height: 10),
                        _overviewCard(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _statSection(),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(flex: 2, child: _welcomeCard()),
                            const SizedBox(width: 10),
                            Flexible(flex: 2, child: _overviewCard()),
                          ],
                        ),
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
                title: context.isIndonesian ? "Pegawai" : "Employees",
                value: totalUser,
                subtitle:
                    context.isIndonesian ? "Jumlah Pegawai" : "Total Employees",
                icon: Icons.people_alt_rounded,
                iconColor: const Color.fromARGB(255, 82, 172, 246),
                isGrowth: true,
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
          ],
        );
      },
    );
  }

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isIndonesian ? "Selamat Datang" : "Welcome Back",
              style: TextStyle(
                color: AppColors.putih.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _cachedNama.isNotEmpty
                          ? _cachedNama.trim().substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cachedNama.split(" ").take(2).join(" "),
                      style: TextStyle(
                        color: AppColors.putih,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _cachedPeran,
                      style: TextStyle(
                        color: AppColors.putih.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                        title: context.isIndonesian
                            ? "Kehadiran Hari ini"
                            : "Today's Attendance",
                        value: "$hadirHariIni / $totalUser",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _todayCard(
                        title: context.isIndonesian
                            ? "Tugas Deadline Hari ini"
                            : "Today's Task Deadlines ",
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

  Widget _todayCard({required String title, required String value}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final fontSize = (availableHeight * 0.28).clamp(24.0, 34.0);

        return _HoverCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: AppColors.putih.withOpacity(0.6),
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _overviewCard() {
    return Consumer2<AbsenProvider, TugasProvider>(
      builder: (context, absenProv, tugasProv, child) {
        // Dapatkan data dari provider
        final totalUser = context.read<UserProvider>().totalUsers;
        final totalTugasSelesai = tugasProv.totalTugasSelesai.toDouble();
        final totalTugas = tugasProv.totalAllTugas.toDouble();

        final jumlahHadirTotal =
            absenProv.allAbsensi.map((a) => a.userId).toSet().length;
        final rate = (totalUser > 0) ? jumlahHadirTotal / totalUser : 0.0;

        final projectRate =
            (totalTugas > 0) ? totalTugasSelesai / totalTugas : 0.0;
        final performance = ((rate * 0.5) + (projectRate * 0.5));
        final overallProgress = (rate + projectRate + performance) / 3.0;

        // Tampilkan loading hanya jika tidak ada data sama sekali
        final bool showLoading = (tugasProv.isLoading &&
                !tugasProv.hasCache &&
                tugasProv.tugasList.isEmpty) ||
            (absenProv.isLoading &&
                !absenProv.hasCache &&
                absenProv.allAbsensi.isEmpty);

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
            child: showLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.putih,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.isIndonesian
                            ? "Gambaran Bulanan"
                            : "Monthly Overview",
                        style: TextStyle(
                          color: AppColors.putih,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _progress(
                                context.isIndonesian
                                    ? "Tugas Diselesaikan"
                                    : "Project Completion",
                                projectRate,
                                const Color(0xFF4EDD53)),
                            const SizedBox(height: 16),
                            _progress(
                                context.isIndonesian
                                    ? "Rate Kehadiran"
                                    : "Attendance Rate",
                                rate,
                                Colors.orange),
                            const SizedBox(height: 16),
                            _progress(
                                context.isIndonesian
                                    ? "Skor Performa"
                                    : "Performance Score",
                                performance,
                                const Color.fromARGB(255, 62, 168, 255)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.isIndonesian
                                      ? "Keseluruhan"
                                      : "Overall",
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

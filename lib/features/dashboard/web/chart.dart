import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/dashboard/web/provider/attendance_chart.dart';
import 'package:provider/provider.dart';

class AttendanceOverviewChart extends StatefulWidget {
  const AttendanceOverviewChart({super.key});

  @override
  State<AttendanceOverviewChart> createState() =>
      _AttendanceOverviewChartState();
}

class _AttendanceOverviewChartState extends State<AttendanceOverviewChart> {
  // ================= FILTER =================
  int selectedYear = DateTime.now().year;
  int selectedMonth = 0;
  int totalUserCount = 0;

  final List<int> availableYears = [
    DateTime.now().year - 1,
    DateTime.now().year,
  ];

  // ================= DATA =================
  static const double _sectionHeight = 420;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final totalUser = context.read<UserProvider>().totalUsers;

      context.read<AttendanceChartProvider>().load(
            totalUser: totalUser.toInt(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isWide ? _desktopLayout(context) : _mobileLayout(context),
          ],
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.isIndonesian
                    ? "Kehadiran Bulanan"
                    : "Monthly Attendance",
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.isIndonesian
                    ? "Statistik kehadiran karyawan"
                    : "Employee attendance statistics",
                style: TextStyle(
                  color: AppColors.putih.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        _dropdownYear(),
      ],
    );
  }

  // ================= PIE HEADER =================
  Widget _pieHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.isIndonesian ? "Status Kehadiran" : "Monthly Attendance",
          style: TextStyle(
            color: AppColors.putih,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.isIndonesian
              ? "Distribusi kehadiran bulanan karyawan"
              : "Monthly Employee attendance distribution",
          style: TextStyle(
            color: AppColors.putih.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ================= DESKTOP =================
  Widget _desktopLayout(BuildContext context) {
    return SizedBox(
      height: _sectionHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _primaryCard(
              child: Column(
                children: [
                  _header(context),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _lineChartSection(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _primaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pieHeader(context),
                  const SizedBox(height: 16),
                  Expanded(child: _pieChartSection(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ================= MOBILE =================
  Widget _mobileLayout(BuildContext context) {
    return Column(
      children: [
        _primaryCard(
          child: SizedBox(
            height: _sectionHeight,
            child: Column(
              children: [
                _header(context),
                const SizedBox(height: 16),
                Expanded(
                  child: _lineChartSection(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _primaryCard(
          child: SizedBox(
            height: _sectionHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pieHeader(context),
                const SizedBox(height: 16),
                Expanded(child: _pieChartSection(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= LINE CHART =================
  Widget _lineChartSection() {
    final chartProvider = context.watch<AttendanceChartProvider>();

    final hadirTepat = chartProvider.tepatWaktuBulanan;
    final hadirTelat = chartProvider.terlambatBulanan;
    final tidakHadir = chartProvider.tidakHadirBulanan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 11,
              minY: 0,
              maxY: 100,
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  //  BACKGROUND
                  getTooltipColor: (LineBarSpot spot) {
                    switch (spot.barIndex) {
                      case 0:
                        return AppColors.primary;
                      default:
                        return AppColors.primary;
                    }
                  },
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final value = spot.y;

                      //  FORMAT ANGKA
                      final formatted = value.toStringAsFixed(1);

                      // ===== STATUS BASED ON LINE =====
                      final String status;
                      final Color statusColor;
                      switch (spot.barIndex) {
                        case 0:
                          status = "On Time";
                          statusColor = AppColors.green;
                          break;
                        case 1:
                          status = "Late";
                          statusColor = AppColors.yellow;
                          break;
                        case 2:
                          status = "Absent";
                          statusColor = AppColors.red;
                          break;
                        default:
                          status = "";
                          statusColor = AppColors.putih;
                      }

                      return LineTooltipItem(
                        "$status\n$formatted%",
                        TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.putih.withOpacity(0.05),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: _chartTitles(),
              lineBarsData: [
                _line(hadirTepat, AppColors.green),
                _line(hadirTelat, AppColors.yellow),
                _line(tidakHadir, AppColors.red),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _legendRow(),
      ],
    );
  }

  LineChartBarData _line(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]),
      ),
      isCurved: true,
      barWidth: 3,
      color: color,
      dotData: FlDotData(show: false),

      // ===== ENTERPRISE AREA STYLE =====
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.25), // dekat garis
            color.withOpacity(0.08), // tengah
            color.withOpacity(0.0), // fade sebelum bawah
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  FlTitlesData _chartTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 20,
          getTitlesWidget: (value, _) => Text(
            "${value.toInt()}%",
            style: TextStyle(
              color: AppColors.putih.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, _) {
            if (value % 1 != 0) return const SizedBox();

            final i = value.toInt();
            if (i < 0 || i > 11) return const SizedBox();

            return Text(
              _monthShort(i + 1),
              style: TextStyle(
                color: AppColors.putih.withOpacity(0.6),
                fontSize: 10,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // ================= PIE CHART =================
  Widget _pieChartSection(BuildContext context) {
    final chartProvider = context.watch<AttendanceChartProvider>();

    final tepatList = chartProvider.tepatWaktuBulanan;
    final telatList = chartProvider.terlambatBulanan;
    final absenList = chartProvider.tidakHadirBulanan;

    final double hadirTepat =
        tepatList.isEmpty ? 0.0 : tepatList.fold(0.0, (a, b) => a + b);

    final double hadirTelat =
        telatList.isEmpty ? 0.0 : telatList.fold(0.0, (a, b) => a + b);

    final double tidakHadir =
        absenList.isEmpty ? 0.0 : absenList.fold(0.0, (a, b) => a + b);

    final double total = hadirTepat + hadirTelat + tidakHadir;

    if (total == 0) {
      return Center(
        child: Text(
          context.isIndonesian ? "Tidak ada data" : "No data available",
          style: TextStyle(color: AppColors.putih.withOpacity(0.6)),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 4,
              sections: [
                _pieSection(hadirTepat, Colors.green),
                _pieSection(hadirTelat, AppColors.yellow),
                _pieSection(tidakHadir, Colors.red),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _pieLegendData(
          context,
          hadirTepat,
          hadirTelat,
          tidakHadir,
          total,
        ),
      ],
    );
  }

  PieChartSectionData _pieSection(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 42,
      showTitle: false,
    );
  }

  // ================= LEGENDS =================
  Widget _legendRow() {
    return Row(
      children: [
        _legendItem(AppColors.green, "On Time"),
        const SizedBox(width: 12),
        _legendItem(AppColors.yellow, "Late"),
        const SizedBox(width: 12),
        _legendItem(AppColors.red, "Absent"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: AppColors.putih.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _pieLegendData(
    BuildContext context,
    double tepat,
    double telat,
    double absen,
    double total,
  ) {
    return Column(
      children: [
        _pieLegendItem(
            context, AppColors.green, "Tepat Waktu", tepat, total.toInt()),
        const SizedBox(height: 8),
        _pieLegendItem(
            context, AppColors.yellow, "Terlambat", telat, total.toInt()),
        const SizedBox(height: 8),
        _pieLegendItem(
            context, AppColors.red, "Tidak Hadir", absen, total.toInt()),
      ],
    );
  }

  Widget _pieLegendItem(
    BuildContext context,
    Color color,
    String label,
    double value,
    int total,
  ) {
    final percent = total == 0 ? 0 : (value / total) * 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: AppColors.putih, fontSize: 12),
            ),
          ],
        ),
        Text(
          "${percent.toStringAsFixed(1)}%",
          style: TextStyle(
            color: AppColors.putih.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ================= DROPDOWNS =================
  Widget _dropdownYear() {
    return _dropdownContainer(
      DropdownButton<int>(
        value: selectedYear,
        underline: const SizedBox(),
        dropdownColor: AppColors.secondary,
        iconEnabledColor: AppColors.putih,
        items: availableYears
            .map((y) => DropdownMenuItem(
                value: y,
                child: Text(
                  y.toString(),
                  style: TextStyle(fontSize: 12, color: AppColors.putih),
                )))
            .toList(),
        onChanged: (v) {
          final value = v ?? selectedYear;
          setState(() => selectedYear = value);
          context.read<AttendanceChartProvider>().setYear(value);
        },
      ),
    );
  }

  Widget _dropdownContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  // ================= HELPERS =================
  String _monthShort(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    return months[m - 1];
  }
}

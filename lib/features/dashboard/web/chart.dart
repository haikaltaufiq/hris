import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';

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

  final List<int> availableYears = [
    DateTime.now().year - 1,
    DateTime.now().year,
  ];

  // ================= DUMMY DATA =================
  final List<double> hadirTepat = [
    70,
    75,
    80,
    85,
    78,
    82,
    88,
    90,
    87,
    83,
    79,
    85
  ];
  final List<double> hadirTelat = [15, 12, 10, 8, 12, 10, 7, 6, 8, 10, 12, 9];
  final List<double> tidakHadir = [15, 13, 10, 7, 10, 8, 5, 4, 5, 7, 9, 6];

  static const double _sectionHeight = 420;

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isIndonesian ? "Kehadiran Bulanan" : "Monthly Attendance",
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
        Row(
          children: [
            _dropdownMonth(),
            const SizedBox(width: 8),
            _dropdownYear(),
          ],
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
                  Text(
                    context.isIndonesian
                        ? "Status Kehadiran Bulanan"
                        : "Monthly Attendance Status",
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
                        : "Monthlu Employee attendance distribution",
                    style: TextStyle(
                      color: AppColors.putih.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
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
        SizedBox(height: _sectionHeight, child: _lineChartContainer()),
        const SizedBox(height: 16),
        SizedBox(height: _sectionHeight, child: _pieChartContainer(context)),
      ],
    );
  }

  // ================= LINE CONTAINER =================
  Widget _lineChartContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: _lineChartSection(),
    );
  }

  // ================= PIE CONTAINER =================
  Widget _pieChartContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: _pieChartSection(context),
    );
  }

  // ================= LINE CHART =================
  Widget _lineChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
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
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.12),
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
          getTitlesWidget: (value, _) {
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
    final total = hadirTepat.reduce((a, b) => a + b) +
        hadirTelat.reduce((a, b) => a + b) +
        tidakHadir.reduce((a, b) => a + b);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 4,
              sections: [
                _pieSection(hadirTepat.last, AppColors.green),
                _pieSection(hadirTelat.last, AppColors.yellow),
                _pieSection(tidakHadir.last, AppColors.red),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _pieLegend(context, total.toInt()),
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

  Widget _pieLegend(BuildContext context, int total) {
    return Column(
      children: [
        _pieLegendItem(
            context, AppColors.green, "Tepat Waktu", hadirTepat.last, total),
        const SizedBox(height: 8),
        _pieLegendItem(
            context, AppColors.yellow, "Terlambat", hadirTelat.last, total),
        const SizedBox(height: 8),
        _pieLegendItem(
            context, AppColors.red, "Tidak Hadir", tidakHadir.last, total),
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
  Widget _dropdownMonth() {
    return _dropdownContainer(
      DropdownButton<int>(
        value: selectedMonth,
        underline: const SizedBox(),
        dropdownColor: AppColors.secondary,
        iconEnabledColor: AppColors.putih,
        items: List.generate(13, (i) {
          return DropdownMenuItem(
            value: i,
            child: Text(
              i == 0
                  ? (context.isIndonesian ? "Semua Bulan" : "All Months")
                  : _monthLabel(i),
              style: TextStyle(fontSize: 12, color: AppColors.putih),
            ),
          );
        }),
        onChanged: (v) => setState(() => selectedMonth = v ?? 0),
      ),
    );
  }

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
        onChanged: (v) => setState(() => selectedYear = v ?? selectedYear),
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

  String _monthLabel(int m) {
    const months = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return months[m];
  }
}

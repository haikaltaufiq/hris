import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/absen_model.dart';

class AttendanceChart extends StatelessWidget {
  const AttendanceChart({super.key});

  static const double _chartContentHeight = 220.0;
  static const double _legendHeight = 40.0;
  static const double _headerHeight = 50.0;

  Map<String, Map<String, int>> _calculateMonthlyData(
      List<AbsenModel> absenList, UserProvider userProvider) {
    final monthlyData = <String, Map<String, int>>{};
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    for (int i = 11; i >= 0; i--) {
      final date = DateTime(currentMonth.year, currentMonth.month - i, 1);
      final monthName = _getMonthName(date.month);
      monthlyData[monthName] = {'present': 0, 'late': 0, 'absent': 0};
    }

    for (final absen in absenList) {
      if (absen.checkinDate == null) continue;

      try {
        final checkinDate = DateTime.parse(absen.checkinDate!);
        final monthsDiff = (now.year - checkinDate.year) * 12 +
            (now.month - checkinDate.month);
        if (monthsDiff >= 0 && monthsDiff < 12) {
          final monthName = _getMonthName(checkinDate.month);
          if (!monthlyData.containsKey(monthName)) continue;

          if (absen.status == "Tepat Waktu") {
            monthlyData[monthName]!['present'] =
                monthlyData[monthName]!['present']! + 1;
          } else if (absen.status == "Telat") {
            monthlyData[monthName]!['late'] =
                monthlyData[monthName]!['late']! + 1;
          } else if (absen.checkinTime != null) {
            final checkinTime = TimeOfDay.fromDateTime(
                DateTime.parse('2000-01-01 ${absen.checkinTime!}'));
            final workStartTime = const TimeOfDay(hour: 8, minute: 0);
            if (_isLate(checkinTime, workStartTime)) {
              monthlyData[monthName]!['late'] =
                  monthlyData[monthName]!['late']! + 1;
            } else {
              monthlyData[monthName]!['present'] =
                  monthlyData[monthName]!['present']! + 1;
            }
          }
        }
      } catch (_) {}
    }

    final allUserIds = userProvider.users.map((u) => u.id).toList();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final checkedInUserIds = absenList
        .where((a) => a.checkinDate == todayStr)
        .map((a) => a.userId?.toString())
        .where((id) => id != null)
        .cast<String>()
        .toList();

    final absentUserIds =
        allUserIds.where((id) => !checkedInUserIds.contains(id)).toList();

    final todayMonth = _getMonthName(now.month);
    if (monthlyData.containsKey(todayMonth)) {
      monthlyData[todayMonth]!['absent'] =
          (monthlyData[todayMonth]!['absent'] ?? 0) + absentUserIds.length;
    }

    return monthlyData;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  bool _isLate(TimeOfDay checkinTime, TimeOfDay workStartTime) {
    final checkinMinutes = checkinTime.hour * 60 + checkinTime.minute;
    final workStartMinutes = workStartTime.hour * 60 + workStartTime.minute;
    return checkinMinutes > workStartMinutes;
  }

  List<BarChartGroupData> _generateBarGroups(
      Map<String, Map<String, int>> monthlyData) {
    final now = DateTime.now();
    final last12Months = <String>[];
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = _getMonthName(date.month);
      last12Months.add(monthName);
    }

    return last12Months.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final monthData =
          monthlyData[month] ?? {'present': 0, 'late': 0, 'absent': 0};
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
              toY: (monthData['present'] ?? 0).toDouble(),
              color: Colors.green,
              width: 12),
          BarChartRodData(
              toY: (monthData['late'] ?? 0).toDouble(),
              color: Colors.orange,
              width: 12),
          BarChartRodData(
              toY: (monthData['absent'] ?? 0).toDouble(),
              color: Colors.red,
              width: 12),
        ],
      );
    }).toList();
  }

  double _getMaxY(Map<String, Map<String, int>> monthlyData) {
    double maxValue = 0;
    for (final dayData in monthlyData.values) {
      final totalPerDay = dayData.values.reduce((a, b) => a + b).toDouble();
      if (totalPerDay > maxValue) maxValue = totalPerDay;
    }
    return maxValue > 0 ? maxValue : 6;
  }

  List<double> _calculateLeftTitles(double maxY) {
    final interval = _getInterval(maxY);
    final titles = <double>[];
    for (double i = 0; i <= maxY; i += interval) {
      titles.add(i);
    }
    if (titles.last < maxY) titles.add(maxY);
    return titles;
  }

  double _getInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    return (maxY / 5).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AbsenProvider, UserProvider>(
      builder: (context, absenProvider, userProvider, child) {
        // PERBAIKAN UTAMA: Gunakan allAbsensi, bukan absensi
        final monthlyData =
            _calculateMonthlyData(absenProvider.allAbsensi, userProvider);
        final barGroups = _generateBarGroups(monthlyData);
        final maxY = _getMaxY(monthlyData);
        final leftTitles = _calculateLeftTitles(maxY);

        return _HoverCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _headerHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.isIndonesian
                                ? 'Kehadiran Bulanan'
                                : 'Monthly Attendance',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: _chartContentHeight,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barGroups: barGroups,
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  if (!leftTitles.contains(value))
                                    return const SizedBox();
                                  return Text(
                                    value.toInt().toString(),
                                    style: GoogleFonts.poppins(
                                      color: AppColors.putih,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final now = DateTime.now();
                                  final monthName = _getMonthName(DateTime(
                                          now.year,
                                          now.month - 11 + value.toInt(),
                                          1)
                                      .month);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      monthName,
                                      style: TextStyle(
                                          color: AppColors.putih, fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _legendHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _LegendItem(
                              color: Colors.green, label: 'Tepat Waktu'),
                          _LegendItem(color: Colors.orange, label: 'Telat'),
                          _LegendItem(color: Colors.red, label: 'Alfa'),
                        ],
                      ),
                    ),
                  ],
                ),

                // overlay loading spinner
                if (absenProvider.isLoading)
                  SizedBox(
                    height: _chartContentHeight + _legendHeight + _headerHeight,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.putih),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// COMPONENTS
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: AppColors.putih, fontSize: 12)),
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hovering
              ? (Matrix4.identity()..translate(0, -4, 0))
              : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}

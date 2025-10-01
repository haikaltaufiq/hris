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

  get totalEmployees => UserProvider().totalUsers;

  // Konstanta untuk height yang konsisten
  static const double _chartContentHeight = 220.0;
  static const double _legendHeight = 40.0;
  static const double _headerHeight = 50.0;

  // Fungsi untuk menghitung data attendance bulanan
  Map<String, Map<String, int>> _calculateMonthlyData(
      List<AbsenModel> absenList, int totalEmployees) {
    final monthlyData = <String, Map<String, int>>{};
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Inisialisasi 12 bulan terakhir
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(currentMonth.year, currentMonth.month - i, 1);
      final monthName = _getMonthName(date.month);
      monthlyData[monthName] = {
        'present': 0,
        'late': 0,
        'absent': 0,
      };
    }

    // Hitung data berdasarkan absensi per bulan
    for (final absen in absenList) {
      if (absen.checkinDate != null) {
        try {
          final checkinDate = DateTime.parse(absen.checkinDate!);

          // Hanya ambil data 12 bulan terakhir
          final monthsDiff = (now.year - checkinDate.year) * 12 +
              (now.month - checkinDate.month);
          if (monthsDiff >= 0 && monthsDiff < 12) {
            final monthName = _getMonthName(checkinDate.month);

            if (monthlyData.containsKey(monthName)) {
              // Logika untuk menentukan status
              if (absen.checkinTime != null) {
                final checkinTime = TimeOfDay.fromDateTime(
                    DateTime.parse('2000-01-01 ${absen.checkinTime!}'));

                // Asumsi jam kerja dimulai jam 8:00
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
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    }

    // Hitung absent untuk bulan ini berdasarkan karyawan yang tidak checkin hari ini
    if (totalEmployees > 0) {
      final todayMonth = _getMonthName(now.month);
      final todayStr = "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')}";

      // Cek apakah sudah lewat jam 12:00
      final currentTime = TimeOfDay.now();
      final cutoffTime = const TimeOfDay(hour: 12, minute: 0);
      final isAfterCutoff = currentTime.hour > cutoffTime.hour ||
          (currentTime.hour == cutoffTime.hour &&
              currentTime.minute >= cutoffTime.minute);

      if (isAfterCutoff) {
        // Hitung berapa karyawan yang sudah checkin hari ini
        final todayCheckins =
            absenList.where((absen) => absen.checkinDate == todayStr).length;

        // Sisanya dianggap absent
        final absentCount = totalEmployees - todayCheckins;

        if (absentCount > 0 && monthlyData.containsKey(todayMonth)) {
          monthlyData[todayMonth]!['absent'] =
              monthlyData[todayMonth]!['absent']! + absentCount;
        }
      }
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
    // Ambil 12 bulan terakhir dari sekarang
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
            toY: monthData['present']!.toDouble(),
            color: Colors.green,
            width: 12,
          ),
          BarChartRodData(
            toY: monthData['late']!.toDouble(),
            color: Colors.orange,
            width: 12,
          ),
          BarChartRodData(
            toY: monthData['absent']!.toDouble(),
            color: Colors.red,
            width: 12,
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(Map<String, Map<String, int>> monthlyData) {
    double maxValue = 0;
    for (final dayData in monthlyData.values) {
      final totalPerDay = dayData.values.reduce((a, b) => a + b).toDouble();
      if (totalPerDay > maxValue) {
        maxValue = totalPerDay;
      }
    }
    return maxValue > 0
        ? maxValue + 1
        : 6; // Minimum 6 untuk tampilan yang baik
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AbsenProvider, UserProvider>(
      builder: (context, absenProvider, userProvider, child) {
        // Jika masih loading dan belum ada cache
        if (absenProvider.isLoading && !absenProvider.hasCache) {
          return _HoverCard(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  SizedBox(
                    height: _headerHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
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
                    ),
                  ),
                  // Chart content section
                  SizedBox(
                    height: _chartContentHeight,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 20),
                          Text(
                            'Loading attendance data...',
                            style:
                                TextStyle(color: AppColors.putih, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Legend section (empty placeholder untuk konsistensi)
                  SizedBox(height: _legendHeight),
                ],
              ),
            ),
          );
        }

        // Jika ada error dan tidak ada data
        if (absenProvider.errorMessage != null &&
            absenProvider.absensi.isEmpty) {
          return _HoverCard(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  SizedBox(
                    height: _headerHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
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
                    ),
                  ),
                  // Chart content section
                  SizedBox(
                    height: _chartContentHeight,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.putih, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load attendance data',
                            style:
                                TextStyle(color: AppColors.putih, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Legend section (empty placeholder untuk konsistensi)
                  SizedBox(height: _legendHeight),
                ],
              ),
            ),
          );
        }

        // Hitung data untuk chart
        final monthlyData = _calculateMonthlyData(
            absenProvider.absensi, userProvider.totalUsers);
        final barGroups = _generateBarGroups(monthlyData);
        final maxY = _getMaxY(monthlyData);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CHART dengan hover effect
            _HoverCard(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
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
                          if (absenProvider.isLoading)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.putih,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Chart content section
                    SizedBox(
                      height: _chartContentHeight,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                String status;
                                switch (rodIndex) {
                                  case 0:
                                    status = 'Present';
                                    break;
                                  case 1:
                                    status = 'Late';
                                    break;
                                  case 2:
                                    status = 'Absent';
                                    break;
                                  default:
                                    status = '';
                                }

                                // Get month name for tooltip
                                final now = DateTime.now();
                                final last12Months = <String>[];
                                for (int i = 11; i >= 0; i--) {
                                  final date =
                                      DateTime(now.year, now.month - i, 1);
                                  final monthName = _getMonthName(date.month);
                                  last12Months.add(monthName);
                                }

                                final monthName = last12Months[groupIndex];

                                return BarTooltipItem(
                                  '$monthName\n$status: ${rod.toY.round()}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.poppins(
                                      color: AppColors.putih, fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  // Generate 12 bulan terakhir
                                  final now = DateTime.now();
                                  final last12Months = <String>[];

                                  for (int i = 11; i >= 0; i--) {
                                    final date =
                                        DateTime(now.year, now.month - i, 1);
                                    final monthName = _getMonthName(date.month);
                                    last12Months.add(monthName);
                                  }

                                  final index = value.toInt();
                                  if (index >= 0 &&
                                      index < last12Months.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        last12Months[index],
                                        style: TextStyle(
                                            color: AppColors.putih,
                                            fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                    // Legend section
                    SizedBox(
                      height: _legendHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _LegendItem(
                                  color: Colors.green,
                                  label: context.isIndonesian
                                      ? 'Hadir'
                                      : 'Present'),
                              _LegendItem(
                                  color: Colors.orange,
                                  label:
                                      context.isIndonesian ? 'Telat' : 'Late'),
                              _LegendItem(
                                  color: Colors.red,
                                  label:
                                      context.isIndonesian ? 'Alfa' : 'Absent'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }
}

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

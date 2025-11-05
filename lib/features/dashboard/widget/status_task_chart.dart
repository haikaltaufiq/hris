import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:provider/provider.dart';

class StatusTaskChart extends StatelessWidget {
  const StatusTaskChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TugasProvider>(
      builder: (context, tugasProvider, child) {
        final chartData = _generateChartData(tugasProvider.tugasList);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HoverCard(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.isIndonesian
                              ? 'Tugas Mingguan'
                              : 'Weekly Task',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.putih,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: chartData.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    color: AppColors.putih.withOpacity(0.5),
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tugasProvider.isLoading
                                        ? 'Loading data...'
                                        : 'No task data available',
                                    style: TextStyle(
                                      color: AppColors.putih.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: _getMaxY(chartData),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: AppColors.putih.withOpacity(0.1),
                                    strokeWidth: 1,
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
                                          color: AppColors.putih,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        const labels = [
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                          'Sun'
                                        ];
                                        final index = value.toInt();
                                        if (index >= 0 &&
                                            index < labels.length) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              labels[index],
                                              style: TextStyle(
                                                color: AppColors.putih,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: AppColors.putih.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                lineBarsData: [
                                  // Line untuk status "Selesai"
                                  LineChartBarData(
                                    isCurved: true,
                                    color: Colors.green,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.green,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.green.withOpacity(0.1),
                                    ),
                                    spots: chartData
                                        .map((data) => FlSpot(
                                            data.dayIndex.toDouble(),
                                            data.selesai.toDouble()))
                                        .toList(),
                                  ),
                                  // Line untuk status "Menunggu Admin"
                                  LineChartBarData(
                                    isCurved: true,
                                    color: Colors.orange,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.deepOrange,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      ),
                                    ),
                                    belowBarData: BarAreaData(show: false),
                                    spots: chartData
                                        .map((data) => FlSpot(
                                            data.dayIndex.toDouble(),
                                            data.proses.toDouble()))
                                        .toList(),
                                  ),
                                  // Line untuk status "Proses"
                                  LineChartBarData(
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.blue,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      ),
                                    ),
                                    belowBarData: BarAreaData(show: false),
                                    spots: chartData
                                        .map((data) => FlSpot(
                                            data.dayIndex.toDouble(),
                                            data.menungguAdmin.toDouble()))
                                        .toList(),
                                  ),
                                ],
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipRoundedRadius: 8,
                                    tooltipPadding: const EdgeInsets.all(8),
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        String status = '';
                                        Color color = Colors.white;

                                        switch (spot.barIndex) {
                                          case 0:
                                            status = 'Selesai';
                                            color = Colors.green;
                                            break;
                                          case 1:
                                            status = 'Proses';
                                            color = Colors.deepOrange;

                                            break;
                                          case 2:
                                            status = 'Menunggu Admin';
                                            color = Colors.blue;
                                            break;
                                        }

                                        final dayIndex = spot.x.toInt();
                                        const days = [
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                          'Sun'
                                        ];
                                        final day = dayIndex < days.length
                                            ? days[dayIndex]
                                            : '';

                                        return LineTooltipItem(
                                          '$day\n$status: ${spot.y.toInt()}',
                                          TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Legend dengan total count
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _LegendItemWithCount(
                              color: Colors.green,
                              label: context.isIndonesian ? 'Selesai' : 'Done',
                              count: _getTotalCount(chartData, 'selesai'),
                            ),
                            _LegendItemWithCount(
                              color: Colors.blue,
                              label: context.isIndonesian
                                  ? 'Menunggu Admin'
                                  : 'Waiting Admin',
                              count: _getTotalCount(chartData, 'menunggu'),
                            ),
                            _LegendItemWithCount(
                              color: Colors.deepOrange,
                              label: context.isIndonesian ? 'Proses' : 'Proses',
                              count: _getTotalCount(chartData, 'proses'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  List<TaskChartData> _generateChartData(List<dynamic> tugasList) {
    // Group tugas by day of week
    final Map<int, Map<String, int>> groupedData = {};

    // Initialize for all days (0=Monday to 6=Sunday)
    for (int i = 0; i < 7; i++) {
      groupedData[i] = {
        'selesai': 0,
        'menunggu_admin': 0,
        'proses': 0,
      };
    }

    for (final tugas in tugasList) {
      try {
        // Parse tanggal mulai untuk menentukan hari dalam seminggu
        final tanggalPenugasan = tugas.tanggalPenugasan;
        if (tanggalPenugasan != null && tanggalPenugasan.isNotEmpty) {
          final date = _parseDate(tanggalPenugasan);
          if (date != null) {
            final dayOfWeek = date.weekday - 1; // 0=Monday, 6=Sunday
            final status = tugas.status?.toLowerCase() ?? '';

            switch (status) {
              case 'selesai':
              case 'completed':
              case 'done':
                groupedData[dayOfWeek]!['selesai'] =
                    groupedData[dayOfWeek]!['selesai']! + 1;
                break;
              case 'menunggu admin':
              case 'pending':
              case 'waiting':
                groupedData[dayOfWeek]!['menunggu_admin'] =
                    groupedData[dayOfWeek]!['menunggu_admin']! + 1;
                break;
              case 'proses':
              case 'progress':
              case 'processing':
              case 'in progress':
                groupedData[dayOfWeek]!['proses'] =
                    groupedData[dayOfWeek]!['proses']! + 1;
                break;
            }
          }
        }
      } catch (e) {
        // print('Error parsing tugas data: $e');
      }
    }

    // Convert to TaskChartData list
    return groupedData.entries.map((entry) {
      final dayIndex = entry.key;
      final data = entry.value;

      return TaskChartData(
        dayIndex: dayIndex,
        selesai: data['selesai'] ?? 0,
        menungguAdmin: data['menunggu_admin'] ?? 0,
        proses: data['proses'] ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
  }

  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        // Handle dd/MM/yyyy format
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } else if (dateStr.contains('-')) {
        // Handle yyyy-MM-dd format
        return DateTime.parse(dateStr);
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      // print('Date parsing error: $e');
      return null;
    }
  }

  double _getMaxY(List<TaskChartData> data) {
    if (data.isEmpty) return 6;

    double max = 0;
    for (final item in data) {
      final dayMax = [item.selesai, item.menungguAdmin, item.proses]
          .reduce((a, b) => a > b ? a : b)
          .toDouble();
      if (dayMax > max) max = dayMax;
    }

    return max + (max * 0.2).clamp(1, double.infinity);
  }

  int _getTotalCount(List<TaskChartData> data, String type) {
    if (data.isEmpty) return 0;

    switch (type) {
      case 'selesai':
        return data.map((e) => e.selesai).reduce((a, b) => a + b);
      case 'menunggu':
        return data.map((e) => e.menungguAdmin).reduce((a, b) => a + b);
      case 'proses':
        return data.map((e) => e.proses).reduce((a, b) => a + b);
      default:
        return 0;
    }
  }
}

class TaskChartData {
  final int dayIndex; // 0=Monday, 6=Sunday
  final int selesai;
  final int menungguAdmin;
  final int proses;

  TaskChartData({
    required this.dayIndex,
    this.selesai = 0,
    this.menungguAdmin = 0,
    this.proses = 0,
  });

  @override
  String toString() {
    return 'TaskChartData(dayIndex: $dayIndex, selesai: $selesai, menunggu_admin: $menungguAdmin, proses: $proses)';
  }
}

class _LegendItemWithCount extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItemWithCount({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.putih,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            color: AppColors.putih,
            fontSize: 12,
            fontWeight: FontWeight.bold,
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

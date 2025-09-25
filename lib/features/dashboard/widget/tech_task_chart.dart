import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/features/dashboard/chart_provider.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme/app_colors.dart';

class TechTaskChart extends StatelessWidget {
  const TechTaskChart({super.key});

  List<FlSpot> _toSpots(List<double> data) {
    return data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TechTaskStatusProvider>(
      builder: (context, prov, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Performance Trend",
                style: GoogleFonts.poppins(
                  color: AppColors.putih,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Monthly Overview",
                style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.putih.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
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
                            if (value.toInt() >= 0 &&
                                value.toInt() < months.length) {
                              return Text(
                                months[value.toInt()],
                                style: GoogleFonts.poppins(
                                  color: AppColors.putih.withOpacity(0.6),
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 20),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: const Color(0xFF3B82F6),
                        barWidth: 3,
                        spots: _toSpots(prov.target),
                      ),
                      LineChartBarData(
                        isCurved: true,
                        color: const Color(0xFFEF4444),
                        barWidth: 3,
                        spots: _toSpots(prov.attendanceRate),
                      ),
                      LineChartBarData(
                        isCurved: true,
                        color: const Color(0xFF10B981),
                        barWidth: 3,
                        spots: _toSpots(prov.projectCompletion),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: [
                  _Legend(color: const Color(0xFF3B82F6), label: "Target"),
                  _Legend(
                      color: const Color(0xFFEF4444), label: "Attendance Rate"),
                  _Legend(
                      color: const Color(0xFF10B981),
                      label: "Project Completion"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.putih,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';

class AttendanceChart extends StatelessWidget {
  const AttendanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// CHART
        Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Attendance',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.putih,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 6,
                    barTouchData: BarTouchData(enabled: true),
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
                            const labels = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            return Text(
                              labels[value.toInt()],
                              style: TextStyle(
                                  color: AppColors.putih, fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 3, color: Colors.blue, width: 12),
                        BarChartRodData(toY: 2, color: Colors.red, width: 12),
                        BarChartRodData(toY: 1, color: Colors.green, width: 12),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 2, color: Colors.blue, width: 12),
                        BarChartRodData(toY: 3, color: Colors.red, width: 12),
                        BarChartRodData(
                            toY: 4.2, color: Colors.green, width: 12),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 5, color: Colors.blue, width: 12),
                        BarChartRodData(toY: 2, color: Colors.red, width: 12),
                        BarChartRodData(toY: 3, color: Colors.green, width: 12),
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(
                            toY: 3.1, color: Colors.blue, width: 12),
                        BarChartRodData(toY: 4, color: Colors.red, width: 12),
                        BarChartRodData(
                            toY: 4.8, color: Colors.green, width: 12),
                      ]),
                      BarChartGroupData(x: 4, barRods: [
                        BarChartRodData(toY: 4, color: Colors.blue, width: 12),
                        BarChartRodData(toY: 3, color: Colors.red, width: 12),
                        BarChartRodData(toY: 2, color: Colors.green, width: 12),
                      ]),
                      BarChartGroupData(x: 5, barRods: [
                        BarChartRodData(toY: 3, color: Colors.blue, width: 12),
                        BarChartRodData(toY: 2, color: Colors.red, width: 12),
                        BarChartRodData(
                            toY: 5.2, color: Colors.green, width: 12),
                      ]),
                      BarChartGroupData(x: 6, barRods: [
                        BarChartRodData(toY: 4, color: Colors.blue, width: 12),
                        BarChartRodData(toY: 3, color: Colors.red, width: 12),
                        BarChartRodData(
                            toY: 4.5, color: Colors.green, width: 12),
                      ]),
                    ],
                  ),
                ),
              ),

              /// LEGEND
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _LegendItem(color: Colors.blue, label: 'Target'),
                  _LegendItem(color: Colors.red, label: 'Realisasi'),
                  _LegendItem(color: Colors.green, label: 'Forecast'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
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

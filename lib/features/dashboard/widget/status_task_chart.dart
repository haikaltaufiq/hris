import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';

class StatusTaskChart extends StatelessWidget {
  const StatusTaskChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Task Status',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.putih,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          /// CHART
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                gridData: FlGridData(show: true, drawVerticalLine: false),
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
                          style:
                              TextStyle(color: AppColors.putih, fontSize: 10),
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
                  show: true,
                  border: Border.all(color: Colors.white24),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 2),
                      FlSpot(2, 5),
                      FlSpot(3, 3.1),
                      FlSpot(4, 4),
                      FlSpot(5, 3),
                      FlSpot(6, 4),
                    ],
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 3),
                      FlSpot(2, 2),
                      FlSpot(3, 4),
                      FlSpot(4, 3),
                      FlSpot(5, 2),
                      FlSpot(6, 3),
                    ],
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 4.2),
                      FlSpot(2, 3),
                      FlSpot(3, 4.8),
                      FlSpot(4, 2),
                      FlSpot(5, 5.2),
                      FlSpot(6, 4.5),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

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

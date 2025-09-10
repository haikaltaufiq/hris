import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';

class TechTaskChart extends StatefulWidget {
  const TechTaskChart({super.key});

  @override
  State<TechTaskChart> createState() => _TechTaskChartState();
}

class _TechTaskChartState extends State<TechTaskChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernCard(
          child: _buildLineChart(),
          height: 320,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildChartSection(
                  title: "Performance Trend",
                  subtitle: "Monthly Overview",
                  child: _buildLineChart(),
                  legends: [
                    _LegendData(
                        color: const Color(0xFF3B82F6),
                        label: 'Target',
                        value: '85%'),
                    _LegendData(
                        color: const Color(0xFFEF4444),
                        label: 'Realisasi',
                        value: '78%'),
                    _LegendData(
                        color: const Color(0xFF10B981),
                        label: 'Forecast',
                        value: '92%'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _buildChartSection(
                  title: "Task Distribution",
                  subtitle: "Current Status",
                  child: _buildPieChart(),
                  legends: [
                    _LegendData(
                        color: const Color(0xFF3B82F6),
                        label: 'Completed',
                        value: '40%'),
                    _LegendData(
                        color: const Color(0xFFEF4444),
                        label: 'Pending',
                        value: '25%'),
                    _LegendData(
                        color: const Color(0xFF10B981),
                        label: 'In Progress',
                        value: '20%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({required Widget child, double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildChartSection({
    required String title,
    required String subtitle,
    required Widget child,
    required List<_LegendData> legends,
  }) {
    return _buildModernCard(
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppColors.putih,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
          const SizedBox(height: 16),
          _buildLegendGrid(legends),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Column(
      children: [
        if (context.isMobile)
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              "Performance Trend",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.putih,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Expanded(
          child: SizedBox(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.putih.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
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
                          'Jul'
                        ];
                        if (value.toInt() < months.length) {
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
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Target line
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.3),
                          const Color(0xFF3B82F6).withOpacity(0.05),
                        ],
                      ),
                    ),
                    spots: const [
                      FlSpot(0, 3.2),
                      FlSpot(1, 2.8),
                      FlSpot(2, 4.5),
                      FlSpot(3, 3.8),
                      FlSpot(4, 4.2),
                      FlSpot(5, 3.5),
                      FlSpot(6, 4.8),
                    ],
                  ),
                  // Realisasi line
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFFEF4444),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFFEF4444),
                          strokeWidth: 2,
                          strokeColor: AppColors.putih,
                        );
                      },
                    ),
                    spots: const [
                      FlSpot(0, 2.5),
                      FlSpot(1, 3.2),
                      FlSpot(2, 3.8),
                      FlSpot(3, 4.1),
                      FlSpot(4, 3.6),
                      FlSpot(5, 4.5),
                      FlSpot(6, 4.2),
                    ],
                  ),
                  // Forecast line (dashed effect with gradient)
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF10B981),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dashArray: [8, 4],
                    dotData: const FlDotData(show: false),
                    spots: const [
                      FlSpot(3, 4.1),
                      FlSpot(4, 4.5),
                      FlSpot(5, 5.2),
                      FlSpot(6, 5.5),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (context.isMobile)
          _buildLegendGrid([
            _LegendData(
                color: const Color(0xFF3B82F6), label: 'Target', value: '85%'),
            _LegendData(
                color: const Color(0xFFEF4444), label: 'Gagal', value: '78%'),
            _LegendData(
                color: const Color(0xFF10B981), label: 'Selesai', value: '92%'),
          ]),
      ],
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sectionsSpace: 2,
        centerSpaceRadius: 45,
        sections: _buildPieSections(),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final data = [
      {'value': 40.0, 'color': const Color(0xFF3B82F6), 'title': '40%'},
      {'value': 25.0, 'color': const Color(0xFFEF4444), 'title': '25%'},
      {'value': 20.0, 'color': const Color(0xFF10B981), 'title': '20%'},
      {'value': 15.0, 'color': const Color(0xFFF59E0B), 'title': '15%'},
    ];

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = touchedIndex == index;

      return PieChartSectionData(
        color: item['color'] as Color,
        value: item['value'] as double,
        title: isTouched ? item['title'] as String : '',
        radius: isTouched ? 65 : 55,
        titleStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.putih,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  color: AppColors.putih,
                  size: 12,
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildLegendGrid(List<_LegendData> legends) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: legends
          .map((legend) => _ModernLegendItem(
                color: legend.color,
                label: legend.label,
                value: legend.value,
              ))
          .toList(),
    );
  }
}

class _LegendData {
  final Color color;
  final String label;
  final String value;

  _LegendData({required this.color, required this.label, required this.value});
}

class _ModernLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _ModernLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.putih.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // tipis banget
                  blurRadius: 4, // kecil, biar soft
                  spreadRadius: 0,
                  offset: Offset(0, 1), // cuma bawah dikit
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.putih,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.putih.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

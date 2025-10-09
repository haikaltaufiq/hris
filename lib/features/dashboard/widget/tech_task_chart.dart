// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hr/core/theme/app_colors.dart';
// import 'package:hr/core/theme/language_provider.dart';
// import 'package:hr/features/attendance/view_model/absen_provider.dart';
// import 'package:hr/features/dashboard/chart_provider.dart';
// import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
// import 'package:provider/provider.dart';

// class TechTaskChart extends StatelessWidget {
//   const TechTaskChart({super.key});

//   double _getMaxY(
//       Map<String, List<double>> monthlyData, List<double> attendance) {
//     final allValues = <double>[
//       ...monthlyData['target'] ?? [],
//       ...attendance,
//       ...monthlyData['projectCompletion'] ?? [],
//     ];
//     if (allValues.isEmpty) return 10;
//     final maxVal = allValues.reduce((a, b) => a > b ? a : b);
//     return maxVal;
//   }

//   double _getInterval(double maxY) {
//     if (maxY <= 10) return 1;
//     if (maxY <= 20) return 2;
//     if (maxY <= 30) return 3;
//     if (maxY <= 40) return 4;
//     if (maxY <= 50) return 5;
//     if (maxY <= 60) return 6;
//     if (maxY <= 70) return 7;
//     if (maxY <= 80) return 8;
//     if (maxY <= 90) return 9;
//     return 10;
//   }

//   List<BarChartGroupData> _toBarGroups(
//       Map<String, List<double>> monthlyData, List<double> attendance) {
//     final List<BarChartGroupData> groups = [];
//     for (int i = 0; i < 12; i++) {
//       groups.add(
//         BarChartGroupData(
//           x: i,
//           barsSpace: 4,
//           barRods: [
//             BarChartRodData(
//               toY: (monthlyData['target']?[i] ?? 0),
//               color: const Color(0xFF3B82F6),
//               width: 8,
//             ),
//             BarChartRodData(
//               toY: (attendance[i]),
//               color: const Color(0xFFEF4444),
//               width: 8,
//             ),
//             BarChartRodData(
//               toY: (monthlyData['projectCompletion']?[i] ?? 0),
//               color: const Color(0xFF10B981),
//               width: 8,
//             ),
//           ],
//         ),
//       );
//     }
//     return groups;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer3<TugasProvider, TechTaskStatusProvider, AbsenProvider>(
//       builder: (context, tugasProv, statusProv, absenProv, _) {
//         final monthlyData = tugasProv.getMonthlyData();
//         final attendanceData = absenProv.monthlyAttendance;
//         final hasData = (monthlyData['target']?.isNotEmpty ?? false) &&
//             (attendanceData.isNotEmpty) &&
//             (monthlyData['projectCompletion']?.isNotEmpty ?? false);

//         final maxY = _getMaxY(monthlyData, attendanceData);
//         final interval = _getInterval(maxY);

//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 4,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 context.isIndonesian ? 'Trend Performa' : "Performance Trend",
//                 style: GoogleFonts.poppins(
//                   color: AppColors.putih,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 context.isIndonesian ? 'Gambaran Bulanan' : "Monthly Overview",
//                 style: GoogleFonts.poppins(
//                   color: AppColors.putih.withOpacity(0.6),
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 height: 300,
//                 child: hasData
//                     ? BarChart(
//                         BarChartData(
//                           maxY: maxY,
//                           minY: 0,
//                           barGroups: _toBarGroups(monthlyData, attendanceData),
//                           gridData: FlGridData(
//                             show: true,
//                             drawVerticalLine: false,
//                             horizontalInterval: interval,
//                             getDrawingHorizontalLine: (value) => FlLine(
//                               color: AppColors.putih.withOpacity(0.1),
//                               strokeWidth: 1,
//                             ),
//                           ),
//                           titlesData: FlTitlesData(
//                             leftTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 interval: interval,
//                                 reservedSize: 28,
//                                 getTitlesWidget: (value, meta) => Text(
//                                   value.toInt().toString(),
//                                   style: GoogleFonts.poppins(
//                                     color: AppColors.putih,
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             bottomTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 interval: 1,
//                                 getTitlesWidget: (value, meta) {
//                                   const months = [
//                                     'Jan',
//                                     'Feb',
//                                     'Mar',
//                                     'Apr',
//                                     'May',
//                                     'Jun',
//                                     'Jul',
//                                     'Aug',
//                                     'Sep',
//                                     'Oct',
//                                     'Nov',
//                                     'Dec'
//                                   ];
//                                   final index = value.toInt();
//                                   if (index >= 0 && index < months.length) {
//                                     return Padding(
//                                       padding: const EdgeInsets.only(top: 8.0),
//                                       child: Text(
//                                         months[index],
//                                         style: GoogleFonts.poppins(
//                                           color:
//                                               AppColors.putih.withOpacity(0.6),
//                                           fontSize: 10,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                   return const SizedBox();
//                                 },
//                               ),
//                             ),
//                             topTitles: const AxisTitles(
//                               sideTitles: SideTitles(showTitles: false),
//                             ),
//                             rightTitles: const AxisTitles(
//                               sideTitles: SideTitles(showTitles: false),
//                             ),
//                           ),
//                           borderData: FlBorderData(show: false),
//                         ),
//                       )
//                     : const Center(
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 16),
//               Wrap(
//                 spacing: 16,
//                 children: [
//                   _Legend(color: Color(0xFF3B82F6), label: "Target"),
//                   _Legend(
//                       color: Color(0xFFEF4444),
//                       label: context.isIndonesian
//                           ? 'Rate Kehadiran'
//                           : "Attendance Rate"),
//                   _Legend(
//                       color: Color(0xFF10B981),
//                       label: context.isIndonesian
//                           ? 'Project Selesai'
//                           : "Project Completion"),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _Legend extends StatelessWidget {
//   final Color color;
//   final String label;

//   const _Legend({required this.color, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             color: AppColors.putih,
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

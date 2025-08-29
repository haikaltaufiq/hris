import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/dashboard/widget/attendance_chart.dart';
import 'package:hr/features/dashboard/widget/dashboard_card.dart';
import 'package:hr/features/dashboard/widget/status_task_chart.dart';
import 'package:hr/features/dashboard/widget/tech_task_chart.dart';

class DashboardWeb extends StatefulWidget {
  const DashboardWeb({super.key});

  @override
  State<DashboardWeb> createState() => _DashboardWebState();
}

class _DashboardWebState extends State<DashboardWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DashboardCard(),
          // DashboardCardUser(),
          TechTaskChart(),
          AttendanceChart(),
          StatusTaskChart(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/dashboard/widget/attendance_chart.dart';
import 'package:hr/features/dashboard/widget/status_task_chart.dart';
import 'package:hr/features/dashboard/widget/tech_task_chart.dart';
import 'package:hr/features/dashboard/widget/web_card.dart';

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
          // DashboardCard(),
          WebCard(),
          // DashboardCardUser(),
          TechTaskChart(),
          Padding(
            padding:
                const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 16.0),
            child: Row(
              children: [
                Expanded(child: AttendanceChart()),
                const SizedBox(width: 10),
                Expanded(child: StatusTaskChart()),
              ],
            ),
          )
        ],
      ),
    );
  }
}

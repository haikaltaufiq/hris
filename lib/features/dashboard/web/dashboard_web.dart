import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/services/user_service.dart';
import 'package:hr/features/dashboard/web/Dashboarddata.dart';
import 'package:hr/features/dashboard/web/chart.dart';
import 'package:hr/features/dashboard/web/provider/attendance_chart.dart';
import 'package:hr/features/dashboard/web/stats_card.dart';
import 'package:provider/provider.dart';

class DashboardWeb extends StatefulWidget {
  const DashboardWeb({super.key});

  @override
  State<DashboardWeb> createState() => _DashboardWebState();
}

class _DashboardWebState extends State<DashboardWeb> {
  int totalUserCount = 0;

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    final users = await UserService.fetchUsers();

    totalUserCount = users.length;

    context.read<AttendanceChartProvider>().load(
          totalUser: totalUserCount,
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: ListView(
          padding: const EdgeInsets.only(
            right: 16,
            left: 16,
          ),
          children: [
            // DashboardCard(),
            SizedBox(
              height: 14,
            ),
            WebCard(),

            Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
                left: 20.0,
              ),
              child: ChangeNotifierProvider(
                create: (_) => AttendanceChartProvider(),
                child: const AttendanceOverviewChart(),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
                left: 20.0,
              ),
              child: const DashboardData(),
            ),
            const SizedBox(height: 14),
            // DashboardCardUser(),
            // Padding(
            //   padding: const EdgeInsets.only(
            //     right: 20.0,
            //     left: 20.0,
            //   ),
            //   child: Row(
            //     children: [
            //       Expanded(child: AttendanceChart()),
            //       const SizedBox(width: 10),
            //       Expanded(child: StatusTaskChart()),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

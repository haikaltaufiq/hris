import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/dashboard_item.dart';
import 'package:hr/features/dashboard/widget/attendance_chart.dart';
import 'package:hr/features/dashboard/widget/dashboard_card.dart';
import 'package:hr/features/dashboard/widget/dashboard_card_user.dart';
// import 'package:hr/features/dashboard/widget/dashboard_card_user.dart';
import 'package:hr/features/dashboard/widget/dashboard_header.dart';
import 'package:hr/features/dashboard/widget/dashboard_menu.dart';
import 'package:hr/features/dashboard/widget/status_task_chart.dart';
import 'package:hr/routes/app_routes.dart';

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({
    super.key,
  });

  @override
  State<DashboardMobile> createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, bottom: 12, top: 12),
              child: DashboardHeader(),
            ),
            FeatureGuard(
              requiredFeature: 'karyawan',
              child: DashboardCard(),
            ),
            FeatureGuard(
              requiredFeature: 'tambah_lampiran_tugas',
              child: const DashboardCardUser(),
            ),
            FeatureGuard(
              requiredFeature: 'karyawan',
              child: DashboardMenu(
                items: [
                  DashboardMenuItem(
                    label: "Karyawan",
                    icon: FontAwesomeIcons.userGroup,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.employee);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Gaji",
                    icon: FontAwesomeIcons.moneyBill,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.payroll);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Departemen",
                    icon: FontAwesomeIcons.landmark,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.department);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Jabatan",
                    icon: FontAwesomeIcons.sitemap,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.jabatan);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Peran",
                    icon: FontAwesomeIcons.fileShield,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.peran);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Potongan",
                    icon: FontAwesomeIcons.calculator,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.potonganGaji);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Log Aktivitas",
                    icon: FontAwesomeIcons.history,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.logActivity);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Reminder",
                    icon: FontAwesomeIcons.alarmClock,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.reminder);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Info Kantor",
                    icon: FontAwesomeIcons.infoCircle,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.infoKantor);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Danger",
                    icon: FontAwesomeIcons.triangleExclamation,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.danger);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Reset Device",
                    icon: FontAwesomeIcons.trashRestore,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.resetDevice);
                    },
                  ),
                  DashboardMenuItem(
                    label: "Unlock",
                    icon: FontAwesomeIcons.lockOpen,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.bukaAkun);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            const AttendanceChart(),
            const StatusTaskChart(),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

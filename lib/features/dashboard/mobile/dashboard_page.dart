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
              requiredFeature: ['karyawan'],
              child: DashboardCard(),
            ),
            FeatureGuard(
                requiredFeature: ["karyawan", "absensi"],
                child: SizedBox(
                  height: 12,
                )),
            FeatureGuard(
              requiredFeature: ['absensi'],
              child: const DashboardCardUser(),
            ),
            DashboardMenu(
              items: [
                DashboardMenuItem(
                  label: "Karyawan",
                  requiredFeature: 'karyawan',
                  icon: FontAwesomeIcons.userGroup,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.employee);
                  },
                ),
                DashboardMenuItem(
                  label: "Gaji",
                  requiredFeature: 'gaji',
                  icon: FontAwesomeIcons.moneyBill,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.payroll);
                  },
                ),
                DashboardMenuItem(
                  label: "Departemen",
                  requiredFeature: 'departemen',
                  icon: FontAwesomeIcons.landmark,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.department);
                  },
                ),
                DashboardMenuItem(
                  label: "Jabatan",
                  requiredFeature: 'jabatan',
                  icon: FontAwesomeIcons.sitemap,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.jabatan);
                  },
                ),
                DashboardMenuItem(
                  label: "Peran",
                  requiredFeature: 'peran',
                  icon: FontAwesomeIcons.fileShield,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.peran);
                  },
                ),
                DashboardMenuItem(
                  label: "Potongan",
                  requiredFeature: 'potongan_gaji',
                  icon: FontAwesomeIcons.calculator,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.potonganGaji);
                  },
                ),
                DashboardMenuItem(
                  label: "Log Aktivitas",
                  requiredFeature: 'log_aktivitas',
                  icon: FontAwesomeIcons.history,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.logActivity);
                  },
                ),
                DashboardMenuItem(
                  label: "Reminder",
                  requiredFeature: 'pengingat',
                  icon: FontAwesomeIcons.alarmClock,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.reminder);
                  },
                ),
                DashboardMenuItem(
                  label: "Info Kantor",
                  requiredFeature: 'kantor',
                  icon: FontAwesomeIcons.infoCircle,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.infoKantor);
                  },
                ),
                DashboardMenuItem(
                  label: "Reset Data",
                  requiredFeature: 'denger',
                  icon: FontAwesomeIcons.triangleExclamation,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.danger);
                  },
                ),
                DashboardMenuItem(
                  label: "Reset Device",
                  requiredFeature: 'denger',
                  icon: FontAwesomeIcons.trashRestore,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.resetDevice);
                  },
                ),
                DashboardMenuItem(
                  label: "Unlock",
                  requiredFeature: 'deng',
                  icon: FontAwesomeIcons.lockOpen,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.bukaAkun);
                  },
                ),
                DashboardMenuItem(
                  label: "Profile",
                  requiredFeature: 'gaji',
                  icon: FontAwesomeIcons.user,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                DashboardMenuItem(
                  label: "Pengaturan",
                  requiredFeature: 'gaji',
                  icon: FontAwesomeIcons.gear,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.pengaturan);
                  },
                ),
              ],
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

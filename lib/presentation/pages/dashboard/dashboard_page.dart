import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/data/models/dahsboard_menu_item.dart';
import 'package:hr/presentation/layouts/main_layout.dart';
import 'package:hr/presentation/pages/dashboard/widget/dashboard_card.dart';
import 'package:hr/presentation/pages/dashboard/widget/attendance_chart.dart';
import 'package:hr/presentation/pages/dashboard/widget/dashboard_card_user.dart';
import 'package:hr/presentation/pages/dashboard/widget/dashboard_header.dart';
import 'package:hr/presentation/pages/dashboard/widget/dashboard_menu.dart';
import 'package:hr/presentation/pages/dashboard/widget/status_task_chart.dart';
import 'package:hr/presentation/pages/dashboard/widget/tech_task_chart.dart';
import 'package:hr/provider/features/features_guard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DashboardHeader(),
        FeatureGuard(
          featureId: "card_admin",
          child: const DashboardCard(),
        ),
        FeatureGuard(
          featureId: "card_user",
          child: const DashboardCardUser(),
        ),
        DashboardMenu(
          items: [
            DashboardMenuItem(
              label: "Karyawan",
              featureId: "management_karyawan",
              icon: FontAwesomeIcons.userGroup,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MainLayout(externalPageIndex: 0), // KaryawanPage
                  ),
                );
              },
            ),
            DashboardMenuItem(
              label: "Gaji",
              featureId: "gaji",
              icon: FontAwesomeIcons.moneyBill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainLayout(externalPageIndex: 1),
                  ),
                );
              },
            ),
            DashboardMenuItem(
              label: "Departemen",
              featureId: "department",
              icon: FontAwesomeIcons.landmark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainLayout(externalPageIndex: 2),
                  ),
                );
              },
            ),
            DashboardMenuItem(
              label: "Jabatan",
              featureId: "jabatan",
              icon: FontAwesomeIcons.sitemap,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainLayout(externalPageIndex: 3),
                  ),
                );
              },
            ),
            DashboardMenuItem(
              label: "Peran",
              featureId: "peran",
              icon: FontAwesomeIcons.fileShield,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainLayout(externalPageIndex: 4),
                  ),
                );
              },
            ),
            DashboardMenuItem(
              label: "Potongan",
              featureId: "tentang",
              icon: FontAwesomeIcons.calculator,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainLayout(externalPageIndex: 5),
                  ),
                );
              },
            ),
            DashboardMenuItem(
              label: "Log Aktivitas",
              featureId: "log_aktivitas",
              icon: FontAwesomeIcons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainLayout(externalPageIndex: 6),
                  ),
                );
              },
            ),
            DashboardMenuItem(
              label: "Info Kantor",
              featureId: "pengaturan",
              icon: FontAwesomeIcons.info,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainLayout(externalPageIndex: 9),
                  ),
                );
              },
            ),
          ],
        ),
        const AttendanceChart(),
        const TechTaskChart(),
        const StatusTaskChart(),
      ],
    );
  }
}

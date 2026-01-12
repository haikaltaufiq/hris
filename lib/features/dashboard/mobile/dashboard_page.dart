import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
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
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
              FeatureGuard(
                requiredFeature: [
                  'karyawan',
                  'gaji',
                  'departemen',
                  'jabatan',
                  'peran',
                  'potongan_gaji',
                  'log_aktifitas',
                  'pengingat',
                  'kantor',
                  'denger'
                ],
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: DashboardMenu(
                    items: [
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Karyawan" : "Employee",
                        requiredFeature: 'karyawan',
                        icon: FontAwesomeIcons.userGroup,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.employee);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Gaji" : "Salary",
                        requiredFeature: 'gaji',
                        icon: FontAwesomeIcons.moneyBill,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.payroll);
                        },
                      ),
                      DashboardMenuItem(
                        label:
                            context.isIndonesian ? "Departemen" : "Department",
                        requiredFeature: 'departemen',
                        icon: FontAwesomeIcons.landmark,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.department);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Jabatan" : "Position",
                        requiredFeature: 'jabatan',
                        icon: FontAwesomeIcons.sitemap,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.jabatan);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Peran" : "Role",
                        requiredFeature: 'peran',
                        icon: FontAwesomeIcons.fileShield,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.peran);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Potongan" : "Deduction",
                        requiredFeature: 'potongan_gaji',
                        icon: FontAwesomeIcons.calculator,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.potonganGaji);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian
                            ? "Log Aktivitas"
                            : "Activity Log",
                        requiredFeature: 'log_aktifitas',
                        icon: FontAwesomeIcons.history,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.logActivity);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Pengingat" : "Reminder",
                        requiredFeature: 'pengingat',
                        icon: FontAwesomeIcons.alarmClock,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.reminder);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian
                            ? "Info Kantor"
                            : "Office Info",
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
                        label: context.isIndonesian
                            ? "Reset Perangkat"
                            : "Reset Device",
                        requiredFeature: 'denger',
                        icon: FontAwesomeIcons.trashRestore,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.resetDevice);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Buka Akun" : "Unlock",
                        requiredFeature: 'denger',
                        icon: FontAwesomeIcons.lockOpen,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.bukaAkun);
                        },
                      ),
                      DashboardMenuItem(
                        label: context.isIndonesian ? "Pengaturan" : "Settings",
                        requiredFeature: 'gaji',
                        icon: FontAwesomeIcons.gear,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.pengaturan);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              const AttendanceChart(),
              SizedBox(
                height: 12,
              ),
              const StatusTaskChart(),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

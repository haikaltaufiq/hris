import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/features/attendance/absen_page.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page.dart';
import 'package:hr/features/cuti/cuti_page.dart';
import 'package:hr/features/dashboard/dashboard_page.dart';
import 'package:hr/features/dashboard/mobile/dashboard_page.dart';
import 'package:hr/features/department/department_page.dart';
import 'package:hr/features/gaji/gaji_page.dart';
import 'package:hr/features/pengaturan/info_kantor/info_page.dart';
import 'package:hr/features/jabatan/jabatan_page.dart';
import 'package:hr/features/karyawan/karyawan_form/karyawan_form.dart';
import 'package:hr/features/karyawan/karyawan_page.dart';
import 'package:hr/features/landing/landing_page.dart';
import 'package:hr/features/landing/mobile/landing_page.dart';
import 'package:hr/features/auth/login_page.dart';
import 'package:hr/features/lembur/lembur_page.dart';
import 'package:hr/features/log_activity/log_view.dart';
import 'package:hr/features/pengaturan/pengaturan_page.dart';
import 'package:hr/features/peran/peran_form/form_page.dart';
import 'package:hr/features/peran/peran_page.dart';
import 'package:hr/features/potongan/potongan_form/form_edit.dart';
import 'package:hr/features/potongan/potongan_form/potongan_form.dart';
import 'package:hr/features/potongan/potongan_page.dart';
import 'package:hr/features/profile/profile_page.dart';
import 'package:hr/features/reminder/reminder_edit.dart';
import 'package:hr/features/reminder/reminder_form.dart';
import 'package:hr/features/reminder/reminder_page.dart';
import 'package:hr/features/task/task_page.dart';
import 'package:hr/features/task/tugas_form/tugas_edit_form.dart';
import 'package:hr/features/task/tugas_form/tugas_form.dart';
import 'package:hr/layout/main_layout.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const String landingPage = '/';
  static const String landingPageMobile = '/landing_mobile';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String dashboardMobile = '/dashboard_mobile';
  static const String attendance = '/attendance';
  static const String task = '/task';
  static const String overTime = '/lembur';
  static const String leave = '/cuti';
  static const String employee = '/karyawan';
  static const String payroll = '/gaji';
  static const String department = '/department';
  static const String jabatan = '/jabatan';
  static const String potonganGaji = '/potongan_gaji';
  static const String potonganForm = '/potongan_form';
  static const String potonganEdit = '/potongan_edit';
  static const String info = '/info';
  static const String logActivity = '/log_activity';
  static const String peran = '/peran';
  static const String pengaturan = '/pengaturan';
  static const String profile = '/profile';
  static const String tugasForm = '/tugas_form';
  static const String karyawanForm = '/karyawan_form';
  static const String mapPage = '/map_page';
  static const String reminder = '/reminder';
  static const String taskEdit = '/task_edit';
  static const String reminderAdd = '/reminder_add';
  static const String reminderEdit = '/reminder_edit';
  static const String peranForm = '/peran_form';

  // Routes yang tidak memerlukan MainLayout
  static const List<String> _routesWithoutLayout = [
    landingPage,
    landingPageMobile,
    login,
  ];

  /// Universal route helper
  static PageRoute _route(Widget page, RouteSettings settings) {
    if (kIsWeb) {
      // Web → no animation (biar ga geter)
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        settings: settings,
      );
    } else {
      // Mobile → default animasi
      return MaterialPageRoute(
        builder: (_) => page,
        settings: settings,
      );
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? routeName = settings.name;

    switch (routeName) {
      case landingPage:
        return _route(const LandingPage(), settings);

      case landingPageMobile:
        return _route(const LandingPageMobile(), settings);

      case login:
        return _route(const LoginPage(), settings);

      case dashboard:
        return _route(const Dashboard().withMainLayout(dashboard), settings);

      case dashboardMobile:
        return _route(
            const DashboardMobile().withMainLayout(dashboardMobile), settings);

      case attendance:
        return _route(const AbsenPage().withMainLayout(attendance), settings);

      case task:
        return _route(const TaskPage().withMainLayout(task), settings);

      case overTime:
        return _route(const LemburPage().withMainLayout(overTime), settings);

      case leave:
        return _route(const CutiPage().withMainLayout(leave), settings);

      case employee:
        return _route(const KaryawanPage().withMainLayout(employee), settings);

      case payroll:
        return _route(const GajiPage().withMainLayout(payroll), settings);

      case department:
        return _route(
            const DepartmentPage().withMainLayout(department), settings);

      case jabatan:
        return _route(const JabatanPage().withMainLayout(jabatan), settings);

      case potonganGaji:
        return _route(
            const PotonganPage().withMainLayout(potonganGaji), settings);
      case potonganForm:
        return _route(
            const PotonganForm().withMainLayout(potonganForm), settings);
      case potonganEdit:
        final potongan = settings.arguments as PotonganGajiModel;
        return _route(
            PotonganEdit(
              potongan: potongan,
            ).withMainLayout(potonganEdit),
            settings);

      case info:
        return _route(const InfoPage().withMainLayout(info), settings);

      case logActivity:
        return _route(
            const LogActivity().withMainLayout(logActivity), settings);

      case peran:
        return _route(const PeranPage().withMainLayout(peran), settings);

      case tugasForm:
        return _route(const TugasForm().withMainLayout(tugasForm), settings);

      case karyawanForm:
        return _route(
            const KaryawanForm().withMainLayout(karyawanForm), settings);
      case taskEdit:
        final tugas = settings.arguments as TugasModel;
        return _route(
            TugasEditForm(
              tugas: tugas,
            ).withMainLayout(taskEdit),
            settings);

      case reminder:
        return _route(const ReminderPage().withMainLayout(reminder), settings);

      case peranForm:
        final peran = settings.arguments as PeranModel?;
        return _route(
            PeranFormPage(peran: peran).withMainLayout(peranForm), settings);

      case mapPage:
        final args =
            settings.arguments as LatLng; // biar bisa kirim target koordinat
        return _route(MapPage(target: args).withMainLayout(mapPage), settings);

      case pengaturan:
        return _route(
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => PengaturanPage(
              isDarkMode: themeProvider.isDarkMode,
              toggleTheme: themeProvider.toggleTheme,
            ).withMainLayout(pengaturan),
          ),
          settings,
        );

      case profile:
        return _route(const ProfilePage().withMainLayout(profile), settings);

      case reminderAdd:
        return _route(
            const ReminderForm().withMainLayout(reminderAdd), settings);

      case reminderEdit:
        final reminder = settings.arguments as ReminderData;
        return _route(
          ReminderEditForm(reminder: reminder).withMainLayout(reminderEdit),
          settings,
        );

      default:
        return _route(
          const Scaffold(
            body: Center(child: Text("404 Page Not Found")),
          ),
          settings,
        );
    }
  }

  static bool needsMainLayout(String route) {
    return !_routesWithoutLayout.contains(route);
  }
}

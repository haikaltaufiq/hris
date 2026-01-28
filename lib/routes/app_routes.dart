import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/models/tugas_model.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/features/attendance/absen_page.dart';
import 'package:hr/features/attendance/locationTrack/locationTrackPage.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_keluar_page.dart';
import 'package:hr/features/attendance/mobile/absen_form/absen_masuk_page.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page.dart';
import 'package:hr/features/attendance/mobile/components/detail_absen.dart';
import 'package:hr/features/buka_akun/buka_akun.dart';
import 'package:hr/features/cuti/cuti_form/cuti_form.dart';
import 'package:hr/features/cuti/cuti_page.dart';
import 'package:hr/features/danger/danger_page.dart';
import 'package:hr/features/dashboard/dashboard_page.dart';
import 'package:hr/features/dashboard/mobile/dashboard_page.dart';
import 'package:hr/features/department/department_page.dart';
import 'package:hr/features/gaji/gaji_page.dart';
import 'package:hr/features/info_kantor/info_kantor_page.dart';
import 'package:hr/features/karyawan/karyawan_form/karyawan_form_edit.dart';
import 'package:hr/features/lembur/lembur_form/lembur_form.dart';
import 'package:hr/features/reset_device/reset_device.dart';
// import 'package:hr/on_boarding.dart';
import 'package:hr/features/info_kantor/info_page_form.dart';
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
  static const String onboarding = '/onboarding';
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
  static const String infoKantor = '/info_kantor';
  static const String danger = '/danger';
  static const String checkin = '/checkin';
  static const String checkout = '/checkout';
  static const String cutiForm = '/cuti_form';
  static const String lemburForm = '/lembur_form';
  static const String resetDevice = '/resetDevice';
  static const String bukaAkun = '/bukaAkun';
  static const String karyawanEditForm = '/karyawan_edit_form';
  static const String locationTrack = '/locationTrack';
  static const String detailAbsen = '/detailAbsen';

  // Routes yang tidak memerlukan MainLayout
  static const List<String> _routesWithoutLayout = [
    landingPage,
    landingPageMobile,
    login,
    onboarding,
  ];

  /// Universal route helper
  static PageRoute _route(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      settings: settings,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    // Cek autentikasi sederhana
    final box = Hive.box('user');
    final token = box.get('token');

    bool isAuthenticated = token != null && token.isNotEmpty;

// Rute yang dilindungi
    const protectedRoutes = [
      dashboard,
      dashboardMobile,
      attendance,
      task,
      overTime,
      leave,
      employee,
      payroll,
      department,
      jabatan,
      potonganGaji,
      potonganForm,
      potonganEdit,
      info,
      logActivity,
      peran,
      pengaturan,
      profile,
      tugasForm,
      karyawanForm,
      mapPage,
      reminder,
      taskEdit,
      reminderAdd,
      reminderEdit,
      peranForm,
      infoKantor,
      danger,
      checkin,
      checkout,
      cutiForm,
      lemburForm,
      resetDevice,
      bukaAkun,
      karyawanEditForm,
      locationTrack,
      detailAbsen,
    ];

    // Jika URL dilindungi tapi belum login
    if (protectedRoutes.contains(routeName) && !isAuthenticated) {
      return _route(const LoginPage(), settings);
    }
    switch (routeName) {
      // case onboarding:
      //   return _route(const OnBoarding(), settings);

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

      case locationTrack:
        return _route(
            const LocationTrackPage().withMainLayout(locationTrack), settings);

      case detailAbsen:
        final absen = settings.arguments as AbsenModel;
        return _route(
            DetailAbsen(
              selectedAbsen: absen,
            ).withMainLayout((detailAbsen)),
            settings);

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
      case bukaAkun:
        return _route(const BukaAkun().withMainLayout(bukaAkun), settings);

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

      case karyawanEditForm:
        final user = settings.arguments as UserModel;
        return _route(
          KaryawanFormEdit(user: user).withMainLayout(karyawanEditForm),
          settings,
        );

      case taskEdit:
        final tugas = settings.arguments as TugasModel;
        return _route(
            TugasEditForm(
              tugas: tugas,
            ).withMainLayout(taskEdit),
            settings);

      case reminder:
        return _route(const ReminderPage().withMainLayout(reminder), settings);
      case infoKantor:
        return _route(
            const InfoKantorPage().withMainLayout(infoKantor), settings);
      case danger:
        return _route(const DangerPage().withMainLayout(danger), settings);

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
            builder: (context, themeProvider, _) =>
                PengaturanPage().withMainLayout(pengaturan),
          ),
          settings,
        );

      case checkin:
        return _route(const AbsenMasukPage().withMainLayout(checkin), settings);
      case checkout:
        return _route(
            const AbsenKeluarPage().withMainLayout(checkout), settings);

      case cutiForm:
        return _route(const CutiForm().withMainLayout(cutiForm), settings);

      case lemburForm:
        return _route(const LemburForm().withMainLayout(lemburForm), settings);

      case profile:
        return _route(const ProfilePage().withMainLayout(profile), settings);

      case reminderAdd:
        return _route(
            const ReminderForm().withMainLayout(reminderAdd), settings);

      case resetDevice:
        return _route(
            const ResetDevice().withMainLayout(resetDevice), settings);

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

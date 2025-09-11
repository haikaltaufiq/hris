import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/core/utils/local_notification.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
import 'package:hr/features/department/view_model/department_viewmodels.dart';
import 'package:hr/features/gaji/gaji_provider.dart';
import 'package:hr/features/jabatan/jabatan_viewmodels.dart';
import 'package:hr/features/landing/landing_page.dart';
import 'package:hr/features/landing/mobile/landing_page.dart';
import 'package:hr/features/lembur/lembur_viewmodel/lembur_provider.dart';
import 'package:hr/features/peran/peran_viewmodel.dart';
import 'package:hr/features/potongan/view_model/potongan_gaji_provider.dart';
import 'package:hr/features/reminder/reminder_viewmodels.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init local notification
  await NotificationService.instance.init();

  // Init Hive
  await Hive.initFlutter();
  await Hive.openBox('user');
  await Hive.openBox('cuti');
  await Hive.openBox('lembur');
  await Hive.openBox('tugas');
  await Hive.openBox('absen');
  await Hive.openBox('gaji');
  await Hive.openBox('potongan_gaji');
  await Hive.openBox('department');
  await Hive.openBox('jabatan');
  await Hive.openBox('pengingat');
  await Hive.openBox('peran');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TugasProvider()),
        ChangeNotifierProvider(create: (_) => LemburProvider()),
        ChangeNotifierProvider(create: (_) => CutiProvider()),
        ChangeNotifierProvider(create: (_) => PotonganGajiProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentViewModel()),
        ChangeNotifierProvider(create: (_) => JabatanViewModel()),
        ChangeNotifierProvider(create: (_) => AbsenProvider()),
        ChangeNotifierProvider(create: (_) => GajiProvider()),
        ChangeNotifierProvider(create: (_) => PengingatViewModel()),
        ChangeNotifierProvider(create: (_) => PeranViewModel()),
      ],
      child: const PrecacheWrapper(),
    ),
  );
}

/// Wrapper khusus buat preload asset image biar gak kedip
class PrecacheWrapper extends StatefulWidget {
  const PrecacheWrapper({super.key});

  @override
  State<PrecacheWrapper> createState() => _PrecacheWrapperState();
}

class _PrecacheWrapperState extends State<PrecacheWrapper> {
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache background image
    precacheImage(const AssetImage('assets/images/dahua.webp'), context)
        .then((_) {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      // tampilkan blank background biar gak flicker
      return const ColoredBox(color: Colors.black);
    }
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentMode,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      locale: languageProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          if (context.isNativeMobile) {
            return const LandingPageMobile();
          } else {
            return const LandingPage();
          }
        },
      ),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

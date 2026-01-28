import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hr/core/app/app_initializer.dart' show AppInitializer;
import 'package:provider/provider.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/cuti/cuti_viewmodel/cuti_provider.dart';
import 'package:hr/features/dashboard/chart_provider.dart';
import 'package:hr/features/department/view_model/department_viewmodels.dart';
import 'package:hr/features/gaji/gaji_provider.dart';
import 'package:hr/features/jabatan/jabatan_viewmodels.dart';
import 'package:hr/features/lembur/lembur_viewmodel/lembur_provider.dart';
import 'package:hr/features/peran/peran_viewmodel.dart';
import 'package:hr/features/potongan/view_model/potongan_gaji_provider.dart';
import 'package:hr/features/reminder/reminder_viewmodels.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:hr/core/widgets/auth_listener.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FeatureAccess.init();
  await AppInitializer.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> _initialRoute;

  @override
  void initState() {
    super.initState();
    _initialRoute = _getInitialRoute();
  }

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (context.isNativeMobile) {
      return token != null && token.isNotEmpty
          ? AppRoutes.dashboardMobile
          : AppRoutes.landingPageMobile;
    } else {
      return token != null && token.isNotEmpty
          ? AppRoutes.dashboard
          : AppRoutes.landingPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
        ChangeNotifierProvider(create: (_) => TechTaskStatusProvider()),
      ],
      child: FutureBuilder<String>(
        future: _initialRoute,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ColoredBox(color: Colors.black);
          }

          return AuthListener(
            child: _AppContent(initialRoute: snapshot.data!),
          );
        },
      ),
    );
  }
}

class _AppContent extends StatelessWidget {
  final String initialRoute;

  const _AppContent({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, langProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.currentMode,
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: initialRoute,
          onGenerateRoute: AppRoutes.generateRoute,
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("404 Page Not Found")),
            ),
          ),
        );
      },
    );
  }
}

class PrecacheWrapper extends StatefulWidget {
  const PrecacheWrapper({super.key});

  @override
  State<PrecacheWrapper> createState() => _PrecacheWrapperState();
}

class _PrecacheWrapperState extends State<PrecacheWrapper> {
  @override
  void initState() {
    super.initState();
    _precacheAndRemoveSplash();
  }

  Future<void> _precacheAndRemoveSplash() async {
    await AppInitializer.precacheAssets(context);

    try {
      FlutterNativeSplash.remove();
    } catch (e) {
      debugPrint('Splash removal error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

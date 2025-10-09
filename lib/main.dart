import 'dart:ui';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/pengaturan_service.dart';
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
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FeatureAccess.init();
  final themeProvider = ThemeProvider();

  // default hanya sekali
  // Init Hive
  await Hive.initFlutter();
  await Hive.openBox('user');
  await Hive.openBox('cuti');
  await Hive.openBox('lembur');
  await Hive.openBox('tugas');
  await Hive.openBox('absen');
  await Hive.openBox('gaji');
  await Hive.openBox('potongan_gaji');
  await Hive.openBox('departemen');
  await Hive.openBox('jabatan');
  await Hive.openBox('pengingat');
  await Hive.openBox('peran');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
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
      child: const PrecacheWrapper(),
    ),
  );
}

class PrecacheWrapper extends StatefulWidget {
  const PrecacheWrapper({super.key});

  @override
  State<PrecacheWrapper> createState() => _PrecacheWrapperState();
}

class _PrecacheWrapperState extends State<PrecacheWrapper> {
  bool _ready = false;

  final List<String> _imagesToCache = [
    'assets/images/dahua.webp',
  ];

  final List<TextStyle> _fontsToCache = [
    GoogleFonts.poppins(),
    GoogleFonts.roboto(),
  ];

  Future<void> _precacheFonts() async {
    for (final style in _fontsToCache) {
      final painter = TextPainter(
        text: TextSpan(text: "Precache", style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(Canvas(PictureRecorder()), Offset.zero);
    }
  }

  Future<void> _precacheAssets(BuildContext context) async {
    final imageFutures =
        _imagesToCache.map((path) => precacheImage(AssetImage(path), context));
    await Future.wait([...imageFutures, _precacheFonts()]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    if (context.isNativeMobile) {
      _precacheAssets(context).then((_) {
        if (mounted) setState(() => _ready = true);
      });
    } else {
      // langsung ready kalau bukan native mobile
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // kalau bukan native mobile → langsung render MyApp
    if (!context.isNativeMobile) {
      return const MyApp();
    }

    // native mobile, tunggu precache selesai
    if (!_ready) {
      return const SizedBox.shrink(); // transparan, no blank hitam
    }

    return const MyApp();
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<void> _restoreSession(BuildContext context, String token) async {
    // Restore fitur
    await FeatureAccess.init();

    // Restore pengaturan (tema & bahasa)
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final pengaturanService = PengaturanService();

    try {
      final pengaturan = await pengaturanService.getPengaturan(token);
      themeProvider.setDarkMode(pengaturan['tema'] == 'gelap');
      langProvider.toggleLanguage(pengaturan['bahasa'] == 'indonesia');
    } catch (e) {
      debugPrint('Gagal fetch pengaturan otomatis: $e');
    }
  }

  Future<String> _getInitialRoute(
      BuildContext context, bool isNativeMobile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (token != null && token.isNotEmpty) {
      // jika ada token, langsung restore session
      await _restoreSession(context, token);
    }

    if (isNativeMobile) {
      if (!seenOnboarding) return AppRoutes.onboarding;
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
    final themeProvider = context.watch<ThemeProvider>();
    context.watch<LanguageProvider>();
    final isNativeMobile = context.isNativeMobile;

    return FutureBuilder<String>(
      future: _getInitialRoute(context, isNativeMobile),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(color: Colors.black);
        }
        return MaterialApp(

          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.currentMode,
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          // locale: languageProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: snapshot.data,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/core/utils/device_size.dart';
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
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hr/data/services/pengaturan_service.dart';

// variabel global
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Tambahkan ini di luar class manapun, sebelum main
void callbackDispatcher() {
  if (kIsWeb) return; // pastikan tidak jalan di Web
  Workmanager().executeTask((task, inputData) async {
    final batasWaktuString = inputData?['batasWaktu'];
    final tugasId = inputData?['tugasId'];

    if (batasWaktuString == null) return Future.value(true);

    final batasWaktu = DateTime.parse(batasWaktuString);
    final now = DateTime.now();

    final box = await Hive.openBox('tugas');
    final sudahUpload = box.get('uploaded_$tugasId') ?? false;

    if (now.isAfter(batasWaktu) && !sudahUpload) {
      const androidDetails = AndroidNotificationDetails(
        'tugas_channel',
        'Tugas Reminder',
        channelDescription: 'Notifikasi keterlambatan tugas',
        importance: Importance.max,
        priority: Priority.high,
      );

      const platformDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Tugas Terlambat!',
        'Kamu belum upload laporan tugas tepat waktu!',
        platformDetails,
      );
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FeatureAccess.init();
  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    // Setup notification channel
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  for (final box in [
    'user',
    'cuti',
    'lembur',
    'tugas',
    'absen',
    'gaji',
    'potongan_gaji',
    'departemen',
    'jabatan',
    'pengingat',
    'peran',
  ]) {
    await Hive.openBox(box);
  }

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
        ChangeNotifierProvider(create: (_) => TechTaskStatusProvider()),
      ],
      child: const PrecacheWrapper(),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
}

class PrecacheWrapper extends StatefulWidget {
  const PrecacheWrapper({super.key});

  @override
  State<PrecacheWrapper> createState() => _PrecacheWrapperState();
}

class _PrecacheWrapperState extends State<PrecacheWrapper> {
  bool _ready = false;

  final List<String> _imagesToCache = ['assets/images/dahua.webp'];
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
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isNativeMobile) return const MyApp();
    if (!_ready) return const SizedBox.shrink();
    return const MyApp();
  }
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
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground message: ${message.notification?.title}");

      final notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'Notifikasi Penting',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
            ),
          ),
        );
      }
   
    });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;

      if (data['tipe'] == 'tugas_baru') {
        final batasWaktu = DateTime.parse(data['batas_penugasan']);

        // Jalankan notifikasi countdown langsung
        final timerService = TugasProvider();
        timerService.startCountdownNotification(batasWaktu);
      }
    });
  }



  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    // 🔥 LOAD PENGATURAN DARI DATABASE JIKA TOKEN ADA
    if (token != null && token.isNotEmpty) {
      await _loadUserSettings(token);
    }

    if (context.isNativeMobile) {
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

  /// 🔥 Load pengaturan user dari database dan sync ke provider
  Future<void> _loadUserSettings(String token) async {
    try {
      final pengaturanService = PengaturanService();
      final pengaturan = await pengaturanService.getPengaturan(token);

      final tema = pengaturan['tema'] ?? 'terang';
      final bahasa = pengaturan['bahasa'] ?? 'indonesia';

      print('✅ Pengaturan loaded: tema=$tema, bahasa=$bahasa');

      // Sync ke provider
      if (mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        themeProvider.setDarkMode(tema == 'gelap');
        langProvider.toggleLanguage(bahasa == 'indonesia');
      }
    } catch (e) {
      print('❌ Gagal load pengaturan: $e');
      // Jika gagal, gunakan default atau dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        themeProvider.setDarkMode(prefs.getBool('isDarkMode') ?? false);
        langProvider.toggleLanguage(prefs.getString('bahasa') == 'indonesia');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return FutureBuilder<String>(
      future: _initialRoute,
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: snapshot.data!,
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

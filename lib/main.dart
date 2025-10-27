// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_import

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr/data/services/countdown_notification_service.dart';
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
import 'package:permission_handler/permission_handler.dart';


// variabel global
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Tambahkan ini di luar class manapun, sebelum main
void callbackDispatcher() {
    if (kIsWeb) return; // pastikan tidak jalan di Web
    Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    final box = await Hive.openBox('tugas');

    // Cek apakah ada countdown yang perlu diperbarui
    for (final key in box.keys) {
      if (key.startsWith('update_needed_')) {
        final tugasId = key.replaceFirst('update_needed_', '');
        final batasWaktuKey = 'batas_penugasan_$tugasId';
        if (box.containsKey(batasWaktuKey)) {
          final batasWaktu = DateTime.parse(box.get(batasWaktuKey));
          final countdownService = CountdownNotificationService(flutterLocalNotificationsPlugin);
          countdownService.startCountdown(batasWaktu, 'Tugas Diperbarui', int.parse(tugasId));
          
          // Hapus flag agar tidak diulang
          await box.delete('update_needed_$tugasId');
        }
      }
    }
    final now = DateTime.now();

    for (final key in box.keys) {
      if (key.startsWith('batas_penugasan_')) {
        final tugasId = key.replaceFirst('batas_penugasan_', '');
        final batasWaktu = DateTime.parse(box.get(key));

        if (now.isAfter(batasWaktu)) {
          final plugin = FlutterLocalNotificationsPlugin();
          const androidDetails = AndroidNotificationDetails(
            'tugas_channel',
            'Tugas Reminder',
            channelDescription: 'Notifikasi keterlambatan tugas',
            importance: Importance.max,
            priority: Priority.high,
          );
          const platformDetails = NotificationDetails(android: androidDetails);

          await plugin.show(
            tugasId.hashCode,
            '⏰ Tugas Terlambat!',
            'Kamu belum upload laporan tugas tepat waktu!',
            platformDetails,
          );

          // Tandai sudah notifikasi supaya tidak duplikat
          box.put('uploaded_$tugasId', true);
        }
      }
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
  await Firebase.initializeApp();
  final data = message.data;

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  final box = await Hive.openBox('tugas');

  final tipe = data['tipe'];
  final tugasId = data['tugas_id']?.toString() ?? '';
  final judul = data['judul'] ?? 'Tugas';

  // ===============================
  // 1️⃣ TUGAS BARU
  // ===============================
  if (tipe == 'tugas_baru') {
    final batas = DateTime.parse(data['batas_penugasan']);
    await box.put('batas_penugasan_$tugasId', batas.toIso8601String());

    await plugin.show(
      tugasId.hashCode,
      '📌 Tugas Baru',
      'Kamu punya tugas baru: "$judul", deadline: ${batas.toLocal()}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tugas_channel',
          'Tugas Reminder',
          channelDescription: 'Notifikasi keterlambatan tugas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ===============================
  // 2️⃣ TUGAS DIPERBARUI
  // ===============================
  else if (tipe == 'tugas_update') {
    final batasBaru = DateTime.parse(data['batas_penugasan']);
    await box.put('batas_penugasan_$tugasId', batasBaru.toIso8601String());
    await box.put('update_needed_$tugasId', true);

    await plugin.show(
      tugasId.hashCode,
      '⏰ Tugas Diperbarui',
      'Deadline tugas "$judul" diubah ke ${batasBaru.toLocal()}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tugas_channel',
          'Tugas Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ===============================
  // 3️⃣ TUGAS DIHAPUS
  // ===============================
  else if (tipe == 'tugas_hapus') {
    // hapus dari Hive
    await box.delete('batas_penugasan_$tugasId');
    await box.delete('update_needed_$tugasId');

    // cancel notifikasi dan countdown
    await plugin.cancel(tugasId.hashCode);

    await plugin.show(
      tugasId.hashCode,
      '❌ Tugas Dihapus',
      'Tugas "$judul" telah dihapus.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tugas_channel',
          'Tugas Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ===============================
  // 4️⃣ TUGAS DIPINDAHKAN KE ORANG LAIN
  // ===============================
  else if (tipe == 'tugas_pindah') {
    await box.delete('batas_penugasan_$tugasId');
    await box.delete('update_needed_$tugasId');
    await plugin.cancel(tugasId.hashCode);

    await plugin.show(
      tugasId.hashCode,
      '👋 Tugas Dipindahkan',
      'Tugas "$judul" sudah dipindahkan ke pengguna lain.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tugas_channel',
          'Tugas Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ===============================
  // 5️⃣ TUGAS LAMPIRAN DIKIRIM
  // ===============================
  else if (tipe == 'tugas_lampiran') {
    await plugin.show(
      tugasId.hashCode,
      '📎 Lampiran Dikirim',
      'Lampiran baru untuk tugas "$judul" telah dikirim.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tugas_channel',
          'Tugas Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ===============================
  // 6️⃣ TUGAS DIHAPUS OTOMATIS (mis. karena selesai atau dibatalkan)
  // ===============================
  else if (tipe == 'tugas_selesai') {
    await box.delete('batas_penugasan_$tugasId');
    await box.delete('update_needed_$tugasId');
    await plugin.cancel(tugasId.hashCode);

    await plugin.show(
      tugasId.hashCode,
      '✅ Tugas Selesai',
      'Tugas "$judul" sudah diselesaikan.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tugas_channel',
          'Tugas Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final box = await Hive.openBox('tugas');
      for (final key in box.keys) {
        if (key.startsWith('batas_penugasan_')) {
          final tugasId = key.replaceFirst('batas_penugasan_', '');
          final batasWaktu = DateTime.parse(box.get(key));
          final countdownService = CountdownNotificationService(flutterLocalNotificationsPlugin);
          countdownService.startCountdown(batasWaktu, 'Tugas Aktif', int.parse(tugasId));
        }
      }
    });
  }

  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // 🔹 Minta izin notifikasi untuk Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 🔹 Izin standar FCM (untuk iOS & Android)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handler untuk foreground (onMessage)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;
      final plugin = flutterLocalNotificationsPlugin;
      final box = await Hive.openBox('tugas');

      final tipe = data['tipe'];
      final tugasId = int.tryParse(data['tugas_id'] ?? '') ?? 0;
      final judul = data['judul'] ?? 'Tugas';

      // ====== 1. tugas baru ======
      if (tipe == 'tugas_baru') {
        final batasWaktu = DateTime.parse(data['batas_penugasan']);
        await box.put('batas_penugasan_$tugasId', batasWaktu.toIso8601String());
        CountdownNotificationService(plugin).startCountdown(batasWaktu, judul, tugasId);

        await plugin.show(
          tugasId.hashCode,
          '📌 Tugas Baru',
          'Kamu punya tugas baru: "$judul", deadline: ${batasWaktu.toLocal()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tugas_channel',
              'Tugas Reminder',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // ====== 2. tugas diperbarui ======
      else if (tipe == 'tugas_update') {
        final batasWaktu = DateTime.parse(data['batas_penugasan']);
        await box.put('batas_penugasan_$tugasId', batasWaktu.toIso8601String());
        await box.put('update_needed_$tugasId', true);

        // stop countdown lama
        await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
        // mulai countdown baru
        await CountdownNotificationService(plugin).startCountdown(batasWaktu, judul, tugasId);

        await plugin.show(
          tugasId.hashCode,
          '⏰ Tugas Diperbarui',
          'Deadline tugas "$judul" diubah ke ${batasWaktu.toLocal()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tugas_channel',
              'Tugas Reminder',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // ====== 3. tugas dihapus oleh admin ======
      else if (tipe == 'tugas_hapus') {
        // CRITICAL: Stop countdown & cancel notification dulu
        await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
        await plugin.cancel(tugasId.hashCode);
        
        // Baru hapus dari Hive
        await box.delete('batas_penugasan_$tugasId');
        await box.delete('update_needed_$tugasId');
        await box.delete('uploaded_$tugasId');

        // Show notification bahwa tugas dihapus
        await plugin.show(
          999000 + tugasId, // ID berbeda agar tidak tertimpa
          '❌ Tugas Dihapus',
          'Tugas "$judul" telah dihapus oleh admin.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tugas_channel',
              'Tugas Reminder',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // ====== 4. tugas dialihkan ke user lain ======
      else if (tipe == 'tugas_pindah') {
        // CRITICAL: Stop countdown & cancel notification dulu
        await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
        await plugin.cancel(tugasId.hashCode);
        
        // Baru hapus dari Hive
        await box.delete('batas_penugasan_$tugasId');
        await box.delete('update_needed_$tugasId');
        await box.delete('uploaded_$tugasId');

        // Show notification bahwa tugas dipindahkan
        await plugin.show(
          999000 + tugasId, // ID berbeda
          '👋 Tugas Dipindahkan',
          'Tugas "$judul" telah dipindahkan ke pengguna lain.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tugas_channel',
              'Tugas Reminder',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // ====== 5. user kirim lampiran ======
      else if (tipe == 'tugas_lampiran') {
        await plugin.show(
          999000 + tugasId,
          '📎 Lampiran Dikirim',
          'User mengirim lampiran untuk tugas "$judul".',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tugas_channel',
              'Tugas Reminder',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // ====== 6. konfirmasi upload dari user ======
      else if (tipe == 'tugas_lampiran_dikirim') {
        // Stop countdown karena sudah diupload
        await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
        await plugin.cancel(tugasId.hashCode);
        
        await box.delete('batas_penugasan_$tugasId');
        await box.delete('update_needed_$tugasId');

        await plugin.show(
          999000 + tugasId,
          '✅ Lampiran Terkirim',
          'Kamu sudah mengirim lampiran tugas "$judul". Menunggu verifikasi admin.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tugas_channel',
              'Tugas Reminder',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // ====== 7. tugas selesai ======
      else if (tipe == 'tugas_selesai') {
        // Stop countdown & hapus dari Hive karena tugas sudah selesai
        await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
        await plugin.cancel(tugasId.hashCode);
        
        await box.delete('batas_penugasan_$tugasId');
        await box.delete('update_needed_$tugasId');
        await box.delete('uploaded_$tugasId');

        await plugin.show(
          999000 + tugasId,
          '✅ Tugas Selesai - Kerja Bagus!',
          'Selamat! Tugas "$judul" telah disetujui dan diselesaikan.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tugas_channel',
              'Tugas Reminder',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
        );
      }

      // // ====== 8. tugas ditolak ======
      // else if (tipe == 'tugas_ditolak') {
      //   // Tugas ditolak, tapi countdown tetap jalan (bisa upload ulang)
      //   await plugin.show(
      //     999000 + tugasId,
      //     '❌ Tugas Ditolak',
      //     'Tugas "$judul" ditolak. Silakan perbaiki dan upload ulang.',
      //     const NotificationDetails(
      //       android: AndroidNotificationDetails(
      //         'tugas_channel',
      //         'Tugas Reminder',
      //         importance: Importance.max,
      //         priority: Priority.high,
      //         playSound: true,
      //         enableVibration: true,
      //       ),
      //     ),
      //   );
      // }
    });
  }

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    // LOAD PENGATURAN DARI DATABASE JIKA TOKEN ADA
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

  /// Load pengaturan user dari database dan sync ke provider
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

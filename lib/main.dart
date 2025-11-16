// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';

// Services
import 'package:hr/data/services/countdown_notification_service.dart';
import 'package:hr/data/services/pengaturan_service.dart';

// Firebase
import 'package:hr/firebase_options.dart';

// Core
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/core/utils/device_size.dart';

// Features - ViewModels
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

// Localization & Routes
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';

// ==========================================
// GLOBAL VARIABLES
// ==========================================
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ==========================================
// WORKMANAGER CALLBACK
// ==========================================
void callbackDispatcher() {
  if (kIsWeb) return;

  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    final box = await Hive.openBox('tugas');

    // Cek countdown yang perlu diperbarui
    for (final key in box.keys) {
      if (key.startsWith('update_needed_')) {
        final tugasId = key.replaceFirst('update_needed_', '');
        final batasWaktuKey = 'batas_penugasan_$tugasId';

        if (box.containsKey(batasWaktuKey)) {
          final batasWaktu = DateTime.parse(box.get(batasWaktuKey));
          final countdownService =
              CountdownNotificationService(flutterLocalNotificationsPlugin);
          countdownService.startCountdown(
              batasWaktu, 'Tugas Diperbarui', int.parse(tugasId));
          await box.delete('update_needed_$tugasId');
        }
      }
    }

    // Cek tugas yang terlambat
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

          await plugin.show(
            tugasId.hashCode,
            '⏰ Tugas Terlambat!',
            'Kamu belum upload laporan tugas tepat waktu!',
            const NotificationDetails(android: androidDetails),
          );

          box.put('uploaded_$tugasId', true);
        }
      }
    }

    return Future.value(true);
  });
}

// ==========================================
// BACKGROUND MESSAGE HANDLER
// ==========================================
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final data = message.data;
  final plugin = FlutterLocalNotificationsPlugin();
  final box = await Hive.openBox('tugas');

  final tipe = data['tipe'];
  final tugasId = data['tugas_id']?.toString() ?? '';
  final judul = data['judul'] ?? 'Tugas';

  switch (tipe) {
    // ===== TUGAS HANDLERS =====
    case 'tugas_baru':
      final batas = DateTime.parse(data['batas_penugasan']);
      await box.put('batas_penugasan_$tugasId', batas.toIso8601String());
      await _showNotification(plugin, tugasId.hashCode, '📌 Tugas Baru',
          'Kamu punya tugas baru: "$judul", deadline: ${batas.toLocal()}');
      break;

    case 'tugas_update':
      final batasBaru = DateTime.parse(data['batas_penugasan']);
      await box.put('batas_penugasan_$tugasId', batasBaru.toIso8601String());
      await box.put('update_needed_$tugasId', true);
      await _showNotification(plugin, tugasId.hashCode, '⏰ Tugas Diperbarui',
          'Deadline tugas "$judul" diubah ke ${batasBaru.toLocal()}');
      break;

    case 'tugas_hapus':
      await box.delete('batas_penugasan_$tugasId');
      await box.delete('update_needed_$tugasId');
      await plugin.cancel(tugasId.hashCode);
      await _showNotification(plugin, tugasId.hashCode, '❌ Tugas Dihapus',
          'Tugas "$judul" telah dihapus.');
      break;

    case 'tugas_pindah':
      await box.delete('batas_penugasan_$tugasId');
      await box.delete('update_needed_$tugasId');
      await plugin.cancel(tugasId.hashCode);
      await _showNotification(plugin, tugasId.hashCode, '👋 Tugas Dipindahkan',
          'Tugas "$judul" sudah dipindahkan ke pengguna lain.');
      break;

    case 'tugas_lampiran':
      await _showNotification(plugin, tugasId.hashCode, '📎 Lampiran Dikirim',
          'Lampiran baru untuk tugas "$judul" telah dikirim.');
      break;

    case 'tugas_selesai':
      await box.delete('batas_penugasan_$tugasId');
      await box.delete('update_needed_$tugasId');
      await plugin.cancel(tugasId.hashCode);
      await _showNotification(plugin, tugasId.hashCode, '✅ Tugas Selesai',
          'Tugas "$judul" sudah diselesaikan.');
      break;

    case 'tugas_update_proses':
      await _showNotification(
          plugin,
          999000 + int.parse(tugasId),
          '📝 Perhatian',
          'Status tugas "$judul" telah diubah menjadi PROSES. Tolong hubungi admin untuk menanyakan kejelasan.');
      break;

    // ===== CUTI HANDLERS =====
    case 'cuti_diajukan':
      await _showNotification(plugin, data['cuti_id'].hashCode,
          '📝 Pengajuan Cuti Diterima', 'Pengajuan cuti berhasil dikirim.',
          channel: 'cuti_channel', channelName: 'Cuti Notifications');
      break;

    case 'cuti_step1':
      await _showNotification(plugin, data['cuti_id'].hashCode,
          '✅ Cuti Disetujui Tahap Awal', 'Cuti Anda disetujui tahap awal.',
          channel: 'cuti_channel', channelName: 'Cuti Notifications');
      break;

    case 'cuti_disetujui':
      await _showNotification(plugin, data['cuti_id'].hashCode,
          '🎉 Cuti Disetujui Final', 'Selamat! Cuti Anda telah disetujui.',
          channel: 'cuti_channel', channelName: 'Cuti Notifications');
      break;

    case 'cuti_ditolak':
      await _showNotification(plugin, data['cuti_id'].hashCode,
          '❌ Cuti Ditolak', 'Cuti Anda ditolak.',
          channel: 'cuti_channel', channelName: 'Cuti Notifications');
      break;

    case 'cuti_perlu_approval':
    case 'cuti_perlu_approval_final':
      await _showNotification(
        plugin,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title ?? 'Cuti Perlu Persetujuan',
        message.notification?.body ?? 'Ada pengajuan cuti yang perlu disetujui',
        channel: 'cuti_channel',
        channelName: 'Cuti Notifications',
      );
      break;

    // ===== LEMBUR HANDLERS =====
    case 'lembur_diajukan':
      await _showNotification(plugin, data['lembur_id'].hashCode,
          '📝 Pengajuan Lembur Diterima', 'Pengajuan lembur berhasil dikirim.',
          channel: 'lembur_channel', channelName: 'Lembur Notifications');
      break;

    case 'lembur_step1':
      await _showNotification(plugin, data['lembur_id'].hashCode,
          '✅ Lembur Disetujui Tahap Awal', 'Lembur Anda disetujui tahap awal.',
          channel: 'lembur_channel', channelName: 'Lembur Notifications');
      break;

    case 'lembur_disetujui':
      await _showNotification(plugin, data['lembur_id'].hashCode,
          '🎉 Lembur Disetujui Final', 'Selamat! Lembur Anda telah disetujui.',
          channel: 'lembur_channel', channelName: 'Lembur Notifications');
      break;

    case 'lembur_ditolak':
      await _showNotification(plugin, data['lembur_id'].hashCode,
          '❌ Lembur Ditolak', 'Lembur Anda ditolak.',
          channel: 'lembur_channel', channelName: 'Lembur Notifications');
      break;

    case 'lembur_perlu_approval':
    case 'lembur_perlu_approval_final':
      await _showNotification(
        plugin,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title ?? 'Lembur Perlu Persetujuan',
        message.notification?.body ?? 'Ada pengajuan lembur yang perlu disetujui',
        channel: 'lembur_channel',
        channelName: 'Lembur Notifications',
      );
      break;

    // ✅ DEFAULT HANDLER untuk notifikasi yang tidak terduga
    // default:
    //   await _showNotification(
    //     plugin,
    //     DateTime.now().millisecondsSinceEpoch ~/ 1000,
    //     message.notification?.title ?? 'Notifikasi',
    //     message.notification?.body ?? 'Anda mendapat notifikasi baru',
    //     channel: tipe?.contains('lembur') == true
    //         ? 'lembur_channel'
    //         : tipe?.contains('cuti') == true
    //             ? 'cuti_channel'
    //             : 'default_channel',
    //     channelName: tipe?.contains('lembur') == true
    //         ? 'Lembur Notifications'
    //         : tipe?.contains('cuti') == true
    //             ? 'Cuti Notifications'
    //             : 'Default Notifications',
    //   );
    //   break;

  }
}

// Helper function untuk menampilkan notifikasi
Future<void> _showNotification(
  FlutterLocalNotificationsPlugin plugin,
  int id,
  String title,
  String body, {
  String channel = 'tugas_channel',
  String channelName = 'Tugas Reminder',
}) async {
  await plugin.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

// ==========================================
// MAIN FUNCTION
// ==========================================

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FeatureAccess.init();

  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    FlutterNativeSplash.preserve(
        widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  final boxes = [
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
  ];

  for (final box in boxes) {
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

// ==========================================
// PRECACHE WRAPPER
// ==========================================
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
        if (mounted) {
          FlutterNativeSplash.remove();
          setState(() => _ready = true);
        }
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

// ==========================================
// MY APP
// ==========================================
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
    _restoreCountdowns();
  }

  // ========== RESTORE COUNTDOWNS ==========
  void _restoreCountdowns() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final box = await Hive.openBox('tugas');
      for (final key in box.keys) {
        if (key.startsWith('batas_penugasan_')) {
          final tugasId = key.replaceFirst('batas_penugasan_', '');
          final batasWaktu = DateTime.parse(box.get(key));
          final countdownService =
              CountdownNotificationService(flutterLocalNotificationsPlugin);
          countdownService.startCountdown(
              batasWaktu, 'Tugas Aktif', int.parse(tugasId));
        }
      }
    });
  }

  // ========== SETUP FCM ==========
  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // FOREGROUND MESSAGE HANDLER
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // ========== HANDLE FOREGROUND MESSAGE ==========
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final data = message.data;
    final plugin = flutterLocalNotificationsPlugin;
    final box = await Hive.openBox('tugas');

    final tipe = data['tipe'];
    final tugasId = int.tryParse(data['tugas_id'] ?? '') ?? 0;
    final judul = data['judul'] ?? 'Tugas';

    switch (tipe) {
      // ===== TUGAS =====
      case 'tugas_baru':
        await _handleTugasBaru(data, plugin, box, tugasId, judul);
        break;

      case 'tugas_update':
        await _handleTugasUpdate(data, plugin, box, tugasId, judul);
        break;

      case 'tugas_hapus':
        await _handleTugasHapus(plugin, box, tugasId, judul);
        break;

      case 'tugas_pindah':
        await _handleTugasPindah(plugin, box, tugasId, judul);
        break;

      case 'tugas_lampiran':
        await _showNotif(
            plugin,
            999000 + tugasId,
            context.isIndonesian ? '📎 Lampiran Dikirim' : '📎 Attachment Sent',
            context.isIndonesian
                ? 'User mengirim lampiran untuk tugas "$judul".'
                : 'User sent an attachment for the task "$judul".');
        break;

      case 'tugas_lampiran_dikirim':
        await _handleLampiranDikirim(plugin, box, tugasId, judul);
        break;

      case 'tugas_selesai':
        await _handleTugasSelesai(plugin, box, tugasId, judul);
        break;

      case 'tugas_update_proses':
        await _showNotif(
          plugin,
          999000 + tugasId,
          context.isIndonesian
              ? '📝 Setatus Tugas Proses'
              : '📝 Task Status In Progress',
          context.isIndonesian
              ? 'Status tugas "$judul" telah diubah menjadi PROSES. Tolong hubungi admin untuk menanyakan kejelasan.'
              : 'The status of the task "$judul" has been changed to IN PROGRESS. Please contact the admin for clarification.',
          sound: true,
          vibration: true,
        );
        break;

      // ===== CUTI =====
      case 'cuti_diajukan':
        await _handleCutiLemburNotif(data, plugin, 'cuti', 'diajukan');
        break;
      case 'cuti_step1':
        await _handleCutiLemburNotif(data, plugin, 'cuti', 'step1');
        break;
      case 'cuti_disetujui':
        await _handleCutiLemburNotif(data, plugin, 'cuti', 'disetujui');
        break;
      case 'cuti_ditolak':
        await _handleCutiLemburNotif(data, plugin, 'cuti', 'ditolak');
        break;

      case 'cuti_perlu_approval':
      case 'cuti_perlu_approval_final':
        await _showNotif(
          plugin,
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          message.notification?.title ?? 
            (context.isIndonesian ? 'Cuti Perlu Persetujuan' : 'Leave Approval Required'),
          message.notification?.body ?? 
            (context.isIndonesian ? 'Ada pengajuan cuti yang perlu disetujui' : 'Leave application requires approval'),
          channel: 'cuti_channel',
          channelName: 'Cuti Notifications',
          sound: true,
          vibration: true,
        );
        break;

      // ===== LEMBUR =====
      case 'lembur_diajukan':
        await _handleCutiLemburNotif(data, plugin, 'lembur', 'diajukan');
        break;
      case 'lembur_step1':
        await _handleCutiLemburNotif(data, plugin, 'lembur', 'step1');
        break;
      case 'lembur_disetujui':
        await _handleCutiLemburNotif(data, plugin, 'lembur', 'disetujui');
        break;
      case 'lembur_ditolak':
        await _handleCutiLemburNotif(data, plugin, 'lembur', 'ditolak');
        break;

      case 'lembur_perlu_approval':
      case 'lembur_perlu_approval_final':
        await _showNotif(
          plugin,
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          message.notification?.title ?? 
            (context.isIndonesian ? 'Lembur Perlu Persetujuan' : 'Overtime Approval Required'),
          message.notification?.body ?? 
            (context.isIndonesian ? 'Ada pengajuan lembur yang perlu disetujui' : 'Overtime application requires approval'),
          channel: 'lembur_channel',
          channelName: 'Lembur Notifications',
          sound: true,
          vibration: true,
        );
        break;
    }
  }

  // ===== TUGAS HANDLERS =====
  Future<void> _handleTugasBaru(
      Map<String, dynamic> data,
      FlutterLocalNotificationsPlugin plugin,
      Box box,
      int tugasId,
      String judul) async {
    final batasWaktu = DateTime.parse(data['batas_penugasan']);
    await box.put('batas_penugasan_$tugasId', batasWaktu.toIso8601String());
    CountdownNotificationService(plugin)
        .startCountdown(batasWaktu, judul, tugasId);

    await _showNotif(
        plugin,
        tugasId.hashCode,
        context.isIndonesian ? '📌 Tugas Baru' : '📌 New Task',
        context.isIndonesian
            ? 'Kamu punya tugas baru: "$judul", deadline: ${batasWaktu.toLocal()}'
            : 'You have a new task: "$judul", deadline: ${batasWaktu.toLocal()}');
  }

  Future<void> _handleTugasUpdate(
    Map<String, dynamic> data,
    FlutterLocalNotificationsPlugin plugin,
    Box box,
    int tugasId,
    String judul,
  ) async {
    // Ambil batas waktu lama dari Hive (kalau ada)
    final batasLamaStr = box.get('batas_penugasan_$tugasId');
    DateTime? batasLama =
        batasLamaStr != null ? DateTime.parse(batasLamaStr) : null;

    // Ambil batas waktu baru dari data (kalau dikirim)
    DateTime? batasBaru;
    if (data['batas_penugasan'] != null) {
      batasBaru = DateTime.parse(data['batas_penugasan']);
    }

    String pesan; // Variabel pesan yang akan dikirim ke notifikasi

    if (batasBaru != null) {
      // Simpan batas waktu baru ke Hive
      await box.put('batas_penugasan_$tugasId', batasBaru.toIso8601String());
      await box.put('update_needed_$tugasId', true);

      // Cek apakah batas waktu benar-benar berubah
      final berubah =
          batasLama == null || batasLama.isAtSameMomentAs(batasBaru) == false;

      if (berubah) {
        // Jika deadline berubah → ubah countdown & pesan
        await CountdownNotificationService(plugin)
            .stopCountdown(tugasId: tugasId);
        await CountdownNotificationService(plugin)
            .startCountdown(batasBaru, judul, tugasId);

        pesan = context.isIndonesian
            ? 'Deadline tugas "$judul" telah diubah ke ${batasBaru.toLocal()}.'
            : 'The deadline for the task "$judul" has been changed to ${batasBaru.toLocal()}.';
      } else {
        // Deadline sama → tidak perlu restart countdown
        pesan = context.isIndonesian
            ? 'Data tugas "$judul" telah diperbarui oleh admin. Silakan buka halaman tugas.'
            : 'The task data "$judul" has been updated by the admin. Please open the task page.';
      }
    } else {
      // Kalau data tidak ada field batas_penugasan
      pesan = context.isIndonesian
          ? 'Data tugas "$judul" telah diperbarui oleh admin. Silakan buka halaman tugas.'
          : 'The task data "$judul" has been updated by the admin. Please open the task page.';
    }

    // Tampilkan notifikasi sesuai kondisi
    await _showNotif(
      plugin,
      tugasId.hashCode,
      context.isIndonesian ? '⏰ Tugas Diperbarui' : '⏰ Task Updated',
      pesan,
      sound: true,
      vibration: true,
    );
  }

  Future<void> _handleTugasHapus(FlutterLocalNotificationsPlugin plugin,
      Box box, int tugasId, String judul) async {
    await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
    await plugin.cancel(tugasId.hashCode);

    await box.delete('batas_penugasan_$tugasId');
    await box.delete('update_needed_$tugasId');
    await box.delete('uploaded_$tugasId');

    await _showNotif(
        plugin,
        999000 + tugasId,
        context.isIndonesian ? '❌ Tugas Dihapus' : '❌ Task Deleted',
        context.isIndonesian
            ? 'Tugas "$judul" telah dihapus oleh admin.'
            : 'The task "$judul" has been deleted by the admin.');
  }

  Future<void> _handleTugasPindah(FlutterLocalNotificationsPlugin plugin,
      Box box, int tugasId, String judul) async {
    await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
    await plugin.cancel(tugasId.hashCode);

    await box.delete('batas_penugasan_$tugasId');
    await box.delete('update_needed_$tugasId');
    await box.delete('uploaded_$tugasId');

    await _showNotif(
        plugin,
        999000 + tugasId,
        context.isIndonesian ? '👋 Tugas Dipindahkan' : '👋 Task Moved',
        context.isIndonesian
            ? 'Tugas "$judul" telah dipindahkan ke pengguna lain.'
            : 'The task "$judul" has been moved to another user.');
  }

  Future<void> _handleLampiranDikirim(FlutterLocalNotificationsPlugin plugin,
      Box box, int tugasId, String judul) async {
    await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
    await plugin.cancel(tugasId.hashCode);

    await box.delete('batas_penugasan_$tugasId');
    await box.delete('update_needed_$tugasId');

    await _showNotif(
        plugin,
        999000 + tugasId,
        context.isIndonesian ? '✅ Lampiran Terkirim' : '✅ Attachment Sent',
        context.isIndonesian
            ? 'Kamu sudah mengirim lampiran tugas "$judul". Menunggu verifikasi admin.'
            : 'You have sent the attachment for the task "$judul". Waiting for admin verification.');
  }

  Future<void> _handleTugasSelesai(FlutterLocalNotificationsPlugin plugin,
      Box box, int tugasId, String judul) async {
    await CountdownNotificationService(plugin).stopCountdown(tugasId: tugasId);
    await plugin.cancel(tugasId.hashCode);

    await box.delete('batas_penugasan_$tugasId');
    await box.delete('update_needed_$tugasId');
    await box.delete('uploaded_$tugasId');

    await _showNotif(
        plugin,
        999000 + tugasId,
        context.isIndonesian
            ? '✅ Tugas Selesai - Kerja Bagus!'
            : '✅ Task Completed - Good Job!',
        context.isIndonesian
            ? 'Selamat! Tugas "$judul" telah disetujui dan diselesaikan.'
            : 'Congratulations! The task "$judul" has been approved and completed.',
        sound: true,
        vibration: true);
  }

  // ===== CUTI & LEMBUR HANDLER =====
  Future<void> _handleCutiLemburNotif(
      Map<String, dynamic> data,
      FlutterLocalNotificationsPlugin plugin,
      String type,
      String action) async {
    final id = int.tryParse(data['${type}_id'] ?? '') ?? 0;
    final channel = '${type}_channel';
    final channelName =
        type == 'cuti' ? 'Cuti Notifications' : 'Lembur Notifications';

    String title, body;
    bool sound = false, vibration = false;

    switch (action) {
      case 'diajukan':
        title = context.isIndonesian
            ? '📝 Pengajuan ${type == 'cuti' ? 'Cuti' : 'Lembur'} Diterima'
            : '📝 ${type == 'cuti' ? 'Leave' : 'Overtime'} Application Submitted';
        body = type == 'cuti'
            ? context.isIndonesian
                ? 'Pengajuan cuti Anda tanggal ${data['tanggal_mulai']} s/d ${data['tanggal_selesai']} berhasil dikirim.'
                : 'Your leave application from ${data['tanggal_mulai']} to ${data['tanggal_selesai']} has been submitted.'
            : context.isIndonesian
                ? 'Pengajuan lembur Anda tanggal ${data['tanggal']} berhasil dikirim.'
                : 'Your overtime application on ${data['tanggal']} has been submitted.';
        break;
      case 'step1':
        title = context.isIndonesian
            ? '✅ ${type == 'cuti' ? 'Cuti' : 'Lembur'} Disetujui Tahap Awal'
            : '✅ ${type == 'cuti' ? 'Leave' : 'Overtime'} Approved - Initial Stage';
        body = type == 'cuti'
            ? context.isIndonesian
                ? 'Cuti Anda tanggal ${data['tanggal_mulai']} s/d ${data['tanggal_selesai']} disetujui tahap awal.'
                : 'Your leave from ${data['tanggal_mulai']} to ${data['tanggal_selesai']} has been approved at the initial stage.'
            : context.isIndonesian
                ? 'Lembur Anda tanggal ${data['tanggal']} disetujui tahap awal.'
                : 'Your overtime on ${data['tanggal']} has been approved at the initial stage.';
        sound = true;
        break;
      case 'disetujui':
        title = context.isIndonesian
            ? '🎉 ${type == 'cuti' ? 'Cuti' : 'Lembur'} Disetujui Final'
            : '🎉 ${type == 'cuti' ? 'Leave' : 'Overtime'} Approved - Final Stage';
        body = type == 'cuti'
            ? context.isIndonesian
                ? 'Selamat! Cuti Anda tanggal ${data['tanggal_mulai']} s/d ${data['tanggal_selesai']} telah disetujui.'
                : 'Congratulations! Your leave from ${data['tanggal_mulai']} to ${data['tanggal_selesai']} has been approved.'
            : context.isIndonesian
                ? 'Selamat! Lembur Anda tanggal ${data['tanggal']} telah disetujui.'
                : 'Congratulations! Your overtime on ${data['tanggal']} has been approved.';
        sound = true;
        vibration = true;
        break;
      case 'ditolak':
        title = context.isIndonesian
            ? '❌ ${type == 'cuti' ? 'Cuti' : 'Lembur'} Ditolak'
            : '❌ ${type == 'cuti' ? 'Leave' : 'Overtime'} Rejected';
        body = context.isIndonesian
            ? '${type == 'cuti' ? 'Cuti' : 'Lembur'} Anda ditolak. Catatan: ${data['catatan_penolakan'] ?? '-'}'
            : 'Your ${type == 'cuti' ? 'leave' : 'overtime'} has been rejected. Note: ${data['catatan_penolakan'] ?? '-'}';
        sound = true;
        vibration = true;
        break;
      default:
        return;
    }

    await _showNotif(plugin, id.hashCode, title, body,
        channel: channel,
        channelName: channelName,
        sound: sound,
        vibration: vibration);
  }

  // ===== HELPER: SHOW NOTIFICATION =====
  Future<void> _showNotif(
    FlutterLocalNotificationsPlugin plugin,
    int id,
    String title,
    String body, {
    String channel = 'tugas_channel',
    String channelName = 'Tugas Reminder',
    bool sound = false,
    bool vibration = false,
  }) async {
    await plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: sound,
          enableVibration: vibration,
        ),
      ),
    );
  }

  // ========== GET INITIAL ROUTE ==========
  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      await _loadUserSettings(token);
    }

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

  // ========== LOAD USER SETTINGS ==========
  Future<void> _loadUserSettings(String token) async {
    try {
      final pengaturanService = PengaturanService();
      final pengaturan = await pengaturanService.getPengaturan(token);

      final tema = pengaturan['tema'] ?? 'terang';
      final bahasa = pengaturan['bahasa'] ?? 'indonesia';

      // print('✅ Pengaturan loaded: tema=$tema, bahasa=$bahasa');

      if (mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        themeProvider.setDarkMode(tema == 'gelap');
        langProvider.toggleLanguage(bahasa == 'indonesia');
      }
    } catch (e) {
      // print('❌ Gagal load pengaturan: $e');

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

  // ========== BUILD ==========
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
          navigatorKey: navigatorKey,
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

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr/core/config/firebase_config.dart';
import 'package:hr/core/notifications/fcm_handler.dart';
import 'package:hr/core/notifications/local_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hr/firebase_options.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await _initializeOrientation();
    await _initializeFirebase();
    await _initializeNotifications();
    await _initializeHive();
  }

  static Future<void> _initializeOrientation() async {
    if (kIsWeb) return;

    try {
      await Workmanager().initialize(
        FirebaseConfig.callbackDispatcher,
        isInDebugMode: false,
      );

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      debugPrint('Orientation setup error: $e');
    }
  }

  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> _initializeNotifications() async {
    if (kIsWeb) return;

    await LocalNotificationService.initialize();
    await FcmHandler.initialize();
    await _requestNotificationPermission();
  }

  static Future<void> _requestNotificationPermission() async {
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  static Future<void> _initializeHive() async {
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
  }

  static Future<void> precacheAssets(BuildContext context) async {
    if (kIsWeb) return;

    try {
      final imagesToCache = ['assets/images/dahua.webp'];
      final fontsToCache = [
        GoogleFonts.poppins(),
        GoogleFonts.roboto(),
      ];

      final imageFutures =
          imagesToCache.map((path) => precacheImage(AssetImage(path), context));

      await Future.wait([
        ...imageFutures,
        _precacheFonts(fontsToCache),
      ]);
    } catch (e) {
      debugPrint('Precache assets error: $e');
    }
  }

  static Future<void> _precacheFonts(List<TextStyle> fonts) async {
    for (final style in fonts) {
      final painter = TextPainter(
        text: TextSpan(text: "Precache", style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(Canvas(PictureRecorder()), Offset.zero);
    }
  }
}

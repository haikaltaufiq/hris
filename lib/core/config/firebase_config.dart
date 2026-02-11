import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hr/core/notifications/notification_handler.dart';
import 'package:workmanager/workmanager.dart';

class FirebaseConfig {
  static void callbackDispatcher() {
    if (kIsWeb) return;

    Workmanager().executeTask((task, inputData) async {
      await Firebase.initializeApp();
      return Future.value(true);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    await NotificationHandler.handleBackgroundMessage(message);
  }
}

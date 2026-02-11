import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hr/core/config/firebase_config.dart';
import 'package:hr/core/notifications/notification_handler.dart';

class FcmHandler {
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(
      FirebaseConfig.firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen(
      NotificationHandler.handleForegroundMessage,
    );
  }
}

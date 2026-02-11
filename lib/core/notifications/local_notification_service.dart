import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  static Future<void> show(
    int id,
    String title,
    String body, {
    String channel = 'tugas_channel',
    String channelName = 'Tugas Reminder',
    bool sound = false,
    bool vibration = false,
  }) async {
    await _plugin.show(
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
}

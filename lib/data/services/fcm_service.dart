import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static const _fcmKey = 'fcm_token';

  /// ✅ Ambil token FCM device ini
  static Future<String?> getToken() async {
    try {
      await _fcm.requestPermission();
      final prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString(_fcmKey);
      token ??= await _fcm.getToken();

      if (token != null) {
        await prefs.setString(_fcmKey, token);
        if (kDebugMode) print('🔐 FCM Token aktif: $token');
      } else {
        if (kDebugMode) print('⚠️ Token FCM null');
      }

      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Gagal ambil token FCM: $e');
      return null;
    }
  }

  /// ✅ Hapus token FCM dari lokal dan Firebase
  static Future<void> deleteLocalToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmKey);
      await _fcm.deleteToken();
      if (kDebugMode) print('🧹 Token FCM lokal dihapus');
    } catch (e) {
      if (kDebugMode) print('⚠️ Gagal hapus token lokal: $e');
    }
  }
}

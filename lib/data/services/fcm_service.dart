// lib/data/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// ✅ Ambil token FCM device ini
  static Future<String?> getToken() async {
    try {
      await _fcm.requestPermission();
      final token = await _fcm.getToken();

      if (kDebugMode) print('🔐 FCM Token: $token');
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Gagal ambil token FCM: $e');
      return null;
    }
  }

  /// ✅ Hapus token FCM hanya di sisi lokal (tanpa panggil backend)
  static Future<void> deleteLocalToken() async {
    try {
      await _fcm.deleteToken();
      if (kDebugMode) print('🧹 Token FCM lokal dihapus');
    } catch (e) {
      if (kDebugMode) print('⚠️ Gagal hapus token lokal: $e');
    }
  }
}

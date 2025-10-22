// lib/data/services/fcm_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hr/data/api/api_config.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// ✅ Ambil token FCM device ini
  static Future<String?> getToken() async {
    try {
      // Request permission untuk iOS
      await _fcm.requestPermission();

      // Ambil token dari FCM
      final token = await _fcm.getToken();

      if (kDebugMode) {
        print('🔐 FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Gagal ambil token FCM: $e');
      }
      return null;
    }
  }

  /// ✅ Hapus token FCM di backend (saat logout)
  static Future<void> deleteToken(int userId) async {
    try {
      final token = await _fcm.getToken();

      if (token != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/remove-fcm-token'),
          headers: {'Content-Type': 'application/json'},
          body: '{"user_id": $userId, "device_token": "$token"}',
        );
      }

      await _fcm.deleteToken();

      if (kDebugMode) {
        print('🧹 FCM token dihapus untuk user ID $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Gagal hapus token FCM: $e');
      }
    }
  }
}

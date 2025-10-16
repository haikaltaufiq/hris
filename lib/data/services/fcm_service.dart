import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;

class FcmService {
  static Future<void> sendTokenToLaravel(String authToken, int userId) async {
    try {
      // generate FCM token untuk user ini
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        print('❌ Gagal generate FCM token');
        return;
      }

      print('✅ FCM token user $userId: $fcmToken');

      // kirim token ke Laravel
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/save-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'user_id': userId,
          'token': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Token user $userId berhasil disimpan di server');
      } else {
        print('❌ Gagal simpan token: ${response.statusCode}');
        print(response.body);
      }

      // Listener jika token berubah, update ke server
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('🔄 Token user $userId diperbarui: $newToken');
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/save-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'user_id': userId,
            'token': newToken,
          }),
        );
      });
    } catch (e) {
      print('❌ Error saat kirim token ke Laravel: $e');
    }
  }

  static Future<void> sendNotifToUser(
      int userId, String title, String body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/send-notif');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Notifikasi terkirim ke user $userId');
    } else {
      print('❌ Gagal kirim notifikasi: ${response.statusCode}');
      print(response.body);
    }
  }

  static Future<void> deleteToken(int userId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/delete-token');

    print('🟡 [FCM] Mulai proses hapus token user_id: $userId');
    print('🌐 [FCM] Endpoint: $url');

    try {
      // hapus token di server dulu
      print('📡 [FCM] Mengirim request ke server untuk hapus token...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      print('📨 [FCM] Response code: ${response.statusCode}');
      print('📨 [FCM] Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ [FCM] Token FCM user $userId berhasil dihapus di server');

        print('🧹 [FCM] Menghapus token lokal dari Firebase...');
        await FirebaseMessaging.instance.deleteToken();
        print('✅ [FCM] Token FCM lokal berhasil dihapus');
      } else {
        print('❌ [FCM] Gagal hapus token di server: ${response.body}');
      }
    } catch (e, stack) {
      print('⚠️ [FCM] Error deleteToken: $e');
      print('🧩 [FCM] Stacktrace: $stack');
    }

    print('🔚 [FCM] Selesai proses hapus token untuk user_id: $userId');
  }
}

import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AkunService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ Ambil semua akun terkunci
  static Future<List<dynamic>> fetchLockedUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/akun/terkunci'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Gagal fetch akun terkunci: ${response.body}');
    }
  }

  /// ✅ Buka akun terkunci
  static Future<bool> unlockUser(int userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/akun/$userId/terkunci'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}

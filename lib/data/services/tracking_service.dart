import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';
import 'package:hr/data/models/user_model.dart';

class TrackingService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Update lokasi user
  static Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/tracking/update');

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update lokasi');
    }
  }

  static Future<List<UserModel>> getTrackingUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/tracking');
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal ambil data tracking');
    }
  }
}

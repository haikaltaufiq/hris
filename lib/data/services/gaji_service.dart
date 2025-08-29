import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'gaji_model.dart';

class GajiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch gaji
  static Future<List<GajiUser>> fetchGaji() async {
    final token = await getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/gaji'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List users = data['data'];
      return users.map((u) => GajiUser.fromJson(u)).toList();
    } else {
      throw Exception("Gagal mengambil data gaji");
    }
  }
  
  // Update status gaji
  static Future<void> updateStatus(int id, String status) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/gaji/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception("Gagal update status: ${body['message'] ?? response.body}");
    }
  }
}

import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanService {
  // Ambil pengaturan user dari backend
  Future<Map<String, dynamic>> getPengaturan(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/pengaturan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'tema': data['tema'],
        'bahasa': data['bahasa'],
      };
    } else {
      throw Exception('Gagal ambil pengaturan');
    }
  }

  // Update tema dan bahasa
  Future<Map<String, dynamic>> updatePengaturan({
    required String token,
    required String tema,
    required String bahasa,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/pengaturan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'tema': tema, 'bahasa': bahasa}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      // update lokal SharedPreferences juga
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', data['tema'] == 'gelap');
      await prefs.setString('bahasa', data['bahasa']);
      return data;
    } else {
      throw Exception('Gagal update pengaturan');
    }
  }
}

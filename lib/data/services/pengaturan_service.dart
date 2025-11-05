import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanService {
  /// Ambil pengaturan user dari backend
  Future<Map<String, dynamic>> getPengaturan(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/pengaturan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // print('GET Pengaturan - Status: ${response.statusCode}');
      // print('GET Pengaturan - Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Handle different response structures
        final data = json['data'] ?? json;

        final tema = data['tema'] ?? 'terang';
        final bahasa = data['bahasa'] ?? 'indonesia';

        // print('Pengaturan parsed: tema=$tema, bahasa=$bahasa');

        return {
          'tema': tema,
          'bahasa': bahasa,
        };
      } else if (response.statusCode == 404) {
        // Jika pengaturan belum ada, create default
        // print('Pengaturan belum ada, akan create default');
        return await _createDefaultPengaturan(token);
      } else {
        throw Exception('Gagal ambil pengaturan: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error getPengaturan: $e');
      // Return default settings instead of throwing
      return {
        'tema': 'terang',
        'bahasa': 'indonesia',
      };
    }
  }

  /// Create default pengaturan jika belum ada
  Future<Map<String, dynamic>> _createDefaultPengaturan(String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/pengaturan'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'tema': 'terang',
              'bahasa': 'indonesia',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'tema': 'terang',
          'bahasa': 'indonesia',
        };
      }
    } catch (e) {
      // print('Error creating default pengaturan: $e');
    }

    return {
      'tema': 'terang',
      'bahasa': 'indonesia',
    };
  }

  /// Update tema dan bahasa
  Future<Map<String, dynamic>> updatePengaturan({
    required String token,
    required String tema,
    required String bahasa,
  }) async {
    try {
      // print('Update Pengaturan: tema=$tema, bahasa=$bahasa');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/pengaturan'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'tema': tema,
              'bahasa': bahasa,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // print('Update Pengaturan - Status: ${response.statusCode}');
      // print('Update Pengaturan - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final data = json['data'] ?? json;

        // Update lokal SharedPreferences juga
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', tema == 'gelap');
        await prefs.setString('bahasa', bahasa);

        // print('Pengaturan updated successfully');

        return {
          'tema': data['tema'] ?? tema,
          'bahasa': data['bahasa'] ?? bahasa,
        };
      } else {
        throw Exception('Gagal update pengaturan: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error updatePengaturan: $e');
      throw Exception('Gagal update pengaturan: $e');
    }
  }
}

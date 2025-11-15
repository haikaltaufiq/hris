import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/kantor_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KantorService {
  /// Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Ambil data kantor tunggal
  static Future<KantorModel?> getKantor() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/kantor');
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // fleksibel: kalau ada "data" ambil itu, kalau gak langsung objek
      if (decoded is Map<String, dynamic>) {
        final data = decoded["data"] ?? decoded;
        if (data is Map<String, dynamic>) {
          return KantorModel.fromJson(data);
        }
      }
      return null;
    } else if (response.statusCode == 401) {
      throw Exception("Sesi habis, silakan login ulang.");
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  static Future<Map<String, dynamic>> createKantor(KantorModel kantor) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/kantor');

    // Debug payload yang dikirim
    final payload = jsonEncode(kantor.toJson());
    print('📤 POST Request to: $url');
    print('📦 Payload: $payload');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: payload,
    );

    // Debug respons dari BE
    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    return _handleResponse(response,
        successMessage: "Kantor berhasil diperbarui");
  }

  /// Update kantor (kalau API lo butuh)
  static Future<Map<String, dynamic>> updateKantor(
      int id, KantorModel kantor) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/kantor/$id');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(kantor.toJson()),
    );

    return _handleResponse(response,
        successMessage: "Kantor berhasil diperbarui");
  }

  /// Helper buat handle response API
  static Map<String, dynamic> _handleResponse(http.Response response,
      {String? successMessage}) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "success": true,
        "message": successMessage ?? "Berhasil",
      };
    } else if (response.statusCode == 401) {
      throw Exception("Sesi habis, silakan login ulang.");
    } else {
      return {
        "success": false,
        "message": _extractError(response.body),
      };
    }
  }

  /// Helper parsing pesan error
  static String _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded["message"]?.toString() ??
            decoded["error"]?.toString() ??
            body;
      }
      return body;
    } catch (_) {
      return body;
    }
  }
}

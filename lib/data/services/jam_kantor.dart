import 'dart:convert';

import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/kantor_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JamKantor {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<KantorModel?> getKantor() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/kantor/jam');
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

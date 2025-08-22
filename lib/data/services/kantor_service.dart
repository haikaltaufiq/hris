import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hr/data/models/kantor_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KantorService {
  static const String baseUrl = "http://192.168.20.50:8000/api/kantor";

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

    final url = Uri.parse(baseUrl);
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic> && decoded["data"] != null) {
        return KantorModel.fromJson(decoded["data"]);
      }
      return null;
    } else {
      throw Exception("Gagal load kantor: ${response.body}");
    }
  }

  /// Simpan kantor
  static Future<bool> createKantor(KantorModel kantor) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Harap login ulang.');

    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token", 
      },
      body: jsonEncode(kantor.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}

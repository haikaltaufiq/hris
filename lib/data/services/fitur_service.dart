import 'dart:convert';
import 'package:hr/data/models/fitur_model.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FiturService {
  // Ambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch semua fitur
  static Future<List<Fitur>> fetchFitur() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/fitur'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];
      return dataList.map((f) => Fitur.fromJson(f)).toList();
    } else {
      throw Exception('Gagal memuat data fitur: ${response.statusCode}');
    }
  }
}

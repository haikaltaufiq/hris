import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityLogService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil data activity log
  static Future<List<Map<String, dynamic>>> fetchActivityLogs() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/log'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];
      
      return dataList.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat data activity log: ${response.statusCode}');
    }
  }

  // Ambil daftar bulan yang memiliki log
  static Future<List<Map<String, dynamic>>> fetchAvailableMonths() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/log/months'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List dataList = json.decode(response.body);
      return dataList.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat daftar bulan log');
    }
  }

  static Future<void> resetByMonth(int bulan, int tahun) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/log-aktivitas/reset'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'bulan': bulan, 'tahun': tahun}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal reset log: ${response.body}');
    }
  }
}

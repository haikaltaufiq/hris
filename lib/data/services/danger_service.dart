import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DangerService {
  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil daftar bulan (sama untuk semua jenis log)
  static Future<List<Map<String, dynamic>>> fetchAvailableMonths({
    required String jenis, // 'tugas', 'lembur', 'cuti', 'log'
  }) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/danger/$jenis/months'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List dataList = json.decode(response.body);
      return dataList.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat daftar bulan untuk $jenis');
    }
  }

  // General reset (bisa untuk tugas, lembur, cuti)
  static Future<void> resetByMonth({
    required int bulan,
    required int tahun,
    required String jenis, // 'tugas', 'lembur', 'cuti'
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/danger/$jenis/reset'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'bulan': bulan, 'tahun': tahun}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal reset $jenis: ${response.body}');
    }
  }
}

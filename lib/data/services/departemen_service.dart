import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/departemen_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DepartemenService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch departemen
  static Future<List<DepartemenModel>> fetchDepartemen() async {
    final token = await getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/departemen'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];

      return dataList.map((json) => DepartemenModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data departemen: ${response.statusCode}');
    }
  }

  // Tambah departemen
  static Future<Map<String, dynamic>> createDepartemen({
    required String namaDepartemen,
  }) async {
    final token = await getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/departemen'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nama_departemen': namaDepartemen,
      }),
    );

    final responseBody = json.decode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal membuat tugas',
    };
  }

  // Update departemen
  static Future<Map<String, dynamic>> updateDepartemen({
    required int id,
    required String namaDepartemen,
  }) async {
    final token = await getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/departemen/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nama_departemen': namaDepartemen,
      }),
    );

    final responseBody = json.decode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal memperbarui departemen',
    };
  }

  // Hapus departemen
  static Future<Map<String, dynamic>> deleteDepartemen(int id) async {
    final token = await getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/departemen/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final responseBody = json.decode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal menghapus departemen',
    };
  }
}

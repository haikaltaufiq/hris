import 'dart:convert';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PeranService {
  // Ambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch semua peran beserta fitur
  static Future<List<PeranModel>> fetchPeran() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/peran'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];
      return dataList.map((p) => PeranModel.fromJson(p)).toList();
    } else {
      throw Exception('Gagal memuat data peran: ${response.statusCode}');
    }
  }

  // Tambah peran baru beserta fitur
  static Future<String> createPeran(
      String namaPeran, List<int> fiturIds) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/peran'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'nama_peran': namaPeran,
        'fitur_ids': fiturIds,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body['message'] ?? 'Peran berhasil ditambahkan';
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat peran');
    }
  }

  static Future<String> updatePeran(
      int id, String namaPeran, List<int> fiturIds) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/peran/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'nama_peran': namaPeran,
        'fitur_ids': fiturIds,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return body['message'] ?? 'Peran berhasil diperbarui';
    } else {
      throw Exception(body['message'] ?? 'Gagal update peran');
    }
  }

  // Hapus peran
  static Future<void> deletePeran(int id) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/peran/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus peran: ${response.statusCode}');
    }
  }
}

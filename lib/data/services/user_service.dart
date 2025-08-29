import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch user data
  static Future<List<UserModel>> fetchUsers() async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];
      return dataList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data user: ${response.statusCode}');
    }
  }

  // Tambah user baru
  static Future<void> createUser(Map<String, dynamic> karyawanData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(karyawanData),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      final body = json.decode(response.body);
      if (response.statusCode == 422) {
        throw body['errors'] ??
            {
              'error': ['Data tidak valid']
            };
      } else {
        throw body['message'] ?? "Terjadi kesalahan";
      }
    }
  }

  static Future<void> updateUser(
      int id, Map<String, dynamic> karyawanData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/user/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(karyawanData),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final body = json.decode(response.body);
      if (response.statusCode == 422) {
        throw body['errors'] ??
            {
              'error': ['Data tidak valid']
            };
      } else if (response.statusCode == 404) {
        throw 'User tidak ditemukan';
      } else if (response.statusCode == 403) {
        throw 'Tidak memiliki izin untuk mengubah data ini';
      } else {
        throw body['message'] ?? "Terjadi kesalahan saat memperbarui data";
      }
    }
  }

  // Hapus user
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/user/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final body = json.decode(response.body);

    return {
      'message': body['message'] ??
          (response.statusCode == 200
              ? 'User berhasil dihapus'
              : 'Gagal menghapus user'),
    };
  }
}

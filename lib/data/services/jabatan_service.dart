// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/jabatan_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JabatanService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch jabatan
  static Future<List<JabatanModel>> fetchJabatan() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/jabatan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List jabatanList = jsonData['data'];
      return jabatanList.map((json) => JabatanModel.fromJson(json)).toList();
    } else {
      print('Gagal fetch jabatan: ${response.statusCode} ${response.body}');
      throw Exception('Gagal memuat data jabatan');
    }
  }

  // Tambah jabatan
  static Future<Map<String, dynamic>> createJabatan({
    required String namaJabatan,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/jabatan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nama_jabatan': namaJabatan,
      }),
    );

    final responseBody = json.decode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal membuat jabatan',
    };
  }

  // Update jabatan
  static Future<Map<String, dynamic>> updateJabatan({
    required int id,
    required String namaJabatan,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/jabatan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nama_jabatan': namaJabatan,
      }),
    );

    final responseBody = json.decode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal memperbarui jabatan',
    };
  }

  // Hapus jabatan
  static Future<Map<String, dynamic>> deleteJabatan(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/jabatan/$id'),
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

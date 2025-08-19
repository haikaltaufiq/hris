// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hr/data/models/tugas_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasService {
  static const String baseUrl = 'http://192.168.20.50:8000';

  /// Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Format tanggal dd/MM/yyyy → yyyy-MM-dd
  static String _formatDateForApi(String input) {
    input = input.trim();
    final parts = input.split(RegExp(r'[-/ ]+')); // pisah dengan "/" atau "-"
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
    }
    throw FormatException("Format tanggal tidak valid: $input");
  }

  /// Format jam → HH:mm:ss
  static String _formatTime(String time) {
    time = time.trim();
    try {
      // coba format 12 jam (misal 8:30 PM)
      final dateTime = DateFormat.jm().parseStrict(time);
      return DateFormat('HH:mm:ss').format(dateTime);
    } catch (_) {
      // fallback 24 jam (misal 08:30)
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
      }
      throw FormatException("Format waktu tidak valid: $time");
    }
  }

  /// Fetch daftar tugas
  static Future<List<TugasModel>> fetchTugas() async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('$baseUrl/api/tugas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("FETCH STATUS: ${response.statusCode}");
    print("FETCH BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData != null && jsonData['data'] != null) {
        final List tugasList = jsonData['data'];
        return tugasList.map((item) => TugasModel.fromJson(item)).toList();
      } else {
        print("API tidak mengembalikan key 'data'");
        return [];
      }
    } else {
      throw Exception('Gagal memuat data tugas: ${response.statusCode}');
    }
  }

  /// Create tugas baru
  static Future<Map<String, dynamic>> createTugas({
    required String judul,
    required String jamMulai,
    required String tanggalMulai,
    required String tanggalSelesai,
    int? person,
    required String lokasi,
    required String note,
  }) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final Map<String, dynamic> requestBody = {
      'nama_tugas': judul,
      'jam_mulai': _formatTime(jamMulai),
      'tanggal_mulai': _formatDateForApi(tanggalMulai),
      'tanggal_selesai': _formatDateForApi(tanggalSelesai),
      'lokasi': lokasi,
      'instruksi_tugas': note,
    };

    if (person != null) {
      requestBody['user_id'] = person;
    }

    print("CREATE DATA KIRIM: $requestBody");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tugas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("CREATE STATUS: ${response.statusCode}");
      print("CREATE RESPON: ${response.body}");

      final responseBody = json.decode(response.body);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': responseBody['message'] ?? 'Gagal membuat tugas',
      };
    } catch (e, st) {
      print("ERROR CREATE TUGAS: $e");
      print(st);
      return {'success': false, 'message': 'Terjadi error: $e'};
    }
  }

  /// Update tugas
  static Future<Map<String, dynamic>> updateTugas({
    required int id,
    required String judul,
    required String jamMulai,
    required String tanggalMulai,
    required String tanggalSelesai,
    int? person,
    required String lokasi,
    required String note,
  }) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final Map<String, dynamic> requestBody = {
      'nama_tugas': judul,
      'jam_mulai': _formatTime(jamMulai),
      'tanggal_mulai': _formatDateForApi(tanggalMulai),
      'tanggal_selesai': _formatDateForApi(tanggalSelesai),
      'lokasi': lokasi,
      'instruksi_tugas': note,
    };

    if (person != null) {
      requestBody['user_id'] = person;
    }

    print("UPDATE DATA KIRIM: $requestBody");

    final response = await http.put(
      Uri.parse('$baseUrl/api/tugas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE RESPON: ${response.body}");

    final responseBody = json.decode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal update tugas',
    };
  }

  /// Delete tugas
  static Future<Map<String, dynamic>> deleteTugas(int id) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/tugas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE RESPON: ${response.body}");

    final body = json.decode(response.body);

    return {
      'message': body['message'] ??
          (response.statusCode == 200
              ? 'Tugas berhasil dihapus'
              : 'Gagal menghapus tugas'),
    };
  }
}

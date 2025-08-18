// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hr/data/models/tugas_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasService {
  static const String baseUrl = 'http://192.168.20.50:8000';

  //Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch tugas
  static Future<List<TugasModel>> fetchTugas() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('$baseUrl/api/tugas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("STATUS FETCH: ${response.statusCode}");
    print("BODY FETCH: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // pastikan key 'data' ada
      if (jsonData != null && jsonData['data'] != null) {
        final List tugasList = jsonData['data'];
        return tugasList
            .map((item) => TugasModel.fromJson(item))
            .toList();
      } else {
        print("API tidak mengembalikan key 'data'");
        return [];
      }
    } else {
      print('Gagal fetch tugas: ${response.statusCode} ${response.body}');
      throw Exception('Gagal memuat data tugas');
    }
  }


  // Tambah tugas
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
    if (token == null) throw Exception('Token tidak ditemukan. Harap login ulang.');

    // Format tanggal untuk API
    String _formatDateForApi(String input) {
      final parts = input.split(' / ');
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }

    // Format waktu untuk API (24 jam)
    String _formatTime(String time) {
      // Cek apakah input sudah 24 jam (HH:mm) atau 12 jam (h:mm a)
      try {
        // Coba parse 12 jam dulu
        final dateTime = DateFormat('h:mm a').parse(time);
        return DateFormat('HH:mm:ss').format(dateTime);
      } catch (_) {
        // Kalau gagal, anggap 24 jam (HH:mm)
        final parts = time.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return '${hour.toString().padLeft(2,'0')}:${minute.toString().padLeft(2,'0')}:00';
        }
        throw FormatException('Format waktu tidak valid: $time');
      }
    }


    // Siapkan body request
    final requestBody = {
      'nama_tugas': judul,
      'jam_mulai': _formatTime(jamMulai),
      'tanggal_mulai': _formatDateForApi(tanggalMulai),
      'tanggal_selesai': _formatDateForApi(tanggalSelesai),
      'user_id': person ?? '',
      'lokasi': lokasi,
      'instruksi_tugas': note,
    };

    // Debug: lihat data yang dikirim
    print("DATA KIRIM: $requestBody");

    // Kirim request ke API dengan debug untuk mobile
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

      print("STATUS CODE: ${response.statusCode}");
      print("RESPON API: ${response.body}");

      final responseBody = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseBody['message'] ?? 'Gagal membuat tugas',
      };
    } catch (e, stacktrace) {
      print("ERROR SAAT SUBMIT TUGAS: $e");
      print(stacktrace);
      return {
        'success': false,
        'message': 'Terjadi error saat submit: $e',
      };
    }

  }

  // Update tugas
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
    if (token == null) throw Exception('Token tidak ditemukan. Harap login ulang.');

    // Format tanggal untuk API
    String _formatDateForApi(String input) {
      input = input.trim();
      // Jika format sudah YYYY-MM-DD, kembalikan apa adanya
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) return input;

      // Jika format dd / mm / yyyy
      final parts = input.split(RegExp(r'\s*/\s*')); // split dengan / dan hilangkan spasi
      if (parts.length == 3) {
        return "${parts[2]}-${parts[1].padLeft(2,'0')}-${parts[0].padLeft(2,'0')}";
      }
      return input;
    }

    // Format waktu untuk API
    String _formatTime(String time) {
      time = time.trim();

      // Jika sudah HH:mm:ss, kembalikan apa adanya
      if (RegExp(r'^\d{1,2}:\d{2}:\d{2}$').hasMatch(time)) {
        return time;
      }

      // Jika HH:mm, tambahkan ":00"
      if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(time)) {
        return '$time:00';
      }

      // Kalau masih 12 jam (1:16 PM), parse dengan jm
      try {
        final dateTime = DateFormat.jm().parse(time);
        return DateFormat('HH:mm:ss').format(dateTime);
      } catch (e) {
        return time;
      }
    }

    final requestBody = {
      'nama_tugas': judul,
      'jam_mulai': _formatTime(jamMulai),
      'tanggal_mulai': _formatDateForApi(tanggalMulai),
      'tanggal_selesai': _formatDateForApi(tanggalSelesai),
      'lokasi': lokasi,
      'instruksi_tugas': note,
      'user_id': person
      
    };

    // Debug: lihat data yang dikirim
    print("DATA KIRIM: $requestBody");

    final response = await http.put(
      Uri.parse('$baseUrl/api/tugas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    final responseBody = json.decode(response.body);
    print("RESPON API: $responseBody"); 

    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal update tugas',
    };
  }

  // Delete tugas
  static Future<Map<String, dynamic>> deleteTugas(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/tugas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final body = json.decode(response.body);
    
    return {
      'message': body['message'] ??
          (response.statusCode == 200
              ? 'Tugas berhasil dihapus'
              : 'Gagal menghapus tugas'),
    };
  }
}
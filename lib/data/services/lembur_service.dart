// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/lembur_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LemburService {
  // Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch lembur
  static Future<List<LemburModel>> fetchLembur() async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/lembur'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List lemburList = jsonData['data'];
      return lemburList.map((json) => LemburModel.fromJson(json)).toList();
    } else {
      // print('Gagal fetch lembur: ${response.statusCode} ${response.body}');
      throw Exception('Gagal memuat data lembur');
    }
  }

  // Fungsi mengajukan lembur
  static Future<Map<String, dynamic>> createLembur({
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required String deskripsi,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    try {
      tanggal = DateFormat('dd / MM / yyyy')
          .parse(tanggal)
          .toIso8601String()
          .split('T')[0];
    } catch (e) {
      return {
        'success': false,
        'message': 'Format tanggal tidak valid: $tanggal',
      };
    }

    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(jamMulai) ||
        !RegExp(r'^\d{2}:\d{2}$').hasMatch(jamSelesai)) {
      return {
        'success': false,
        'message': 'Format jam tidak valid: $jamMulai - $jamSelesai',
      };
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/lembur'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tanggal': tanggal,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'deskripsi': deskripsi,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': data['message'] ?? 'Lembur berhasil diajukan',
      };
    } else {
      // Jika Laravel kirim errors[]
      if (data is Map && data["errors"] != null) {
        final errors = data["errors"] as Map<String, dynamic>;

        // Ambil error pertama
        final firstKey = errors.keys.first;
        final firstMessage = errors[firstKey][0];

        return {
          'success': false,
          'message': firstMessage,
        };
      }

      // Jika hanya ada "message" (error manual dari backend)
      if (data is Map && data["message"] != null) {
        return {
          'success': false,
          'message': data["message"],
        };
      }

      // Default fallback
      return {
        'success': false,
        'message': 'Gagal mengajukan lembur',
      };
    }
  }

  // // Edit lembur
  // static Future<Map<String, dynamic>> editLembur({
  //   required int id,
  //   required String tanggal,
  //   required String jamMulai,
  //   required String jamSelesai,
  //   required String deskripsi,
  // }) async {
  //   final token = await _getToken();
  //   if (token == null)
  //     throw Exception('Token tidak ditemukan. Harap login ulang.');

  //   // Format tanggal untuk API
  //   String formatDateForApi(String input) {
  //     input = input.trim();
  //     // Jika format sudah YYYY-MM-DD, kembalikan apa adanya
  //     if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) return input;

  //     // Jika format dd / mm / yyyy
  //     final parts =
  //         input.split(RegExp(r'\s*/\s*')); // split dengan / dan hilangkan spasi
  //     if (parts.length == 3) {
  //       return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
  //     }
  //     return input;
  //   }

  //   // Format waktu untuk API
  //   String formatTime(String time) {
  //     time = time.trim();

  //     // Jika sudah HH:mm:ss, kembalikan apa adanya
  //     if (RegExp(r'^\d{1,2}:\d{2}:\d{2}$').hasMatch(time)) {
  //       return time;
  //     }

  //     // Jika HH:mm, tambahkan ":00"
  //     if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(time)) {
  //       return '$time:00';
  //     }

  //     // Kalau masih 12 jam (1:16 PM), parse dengan jm
  //     try {
  //       final dateTime = DateFormat.jm().parse(time);
  //       return DateFormat('HH:mm:ss').format(dateTime);
  //     } catch (e) {
  //       return time;
  //     }
  //   }

  //   final response = await http.put(
  //     Uri.parse('${ApiConfig.baseUrl}/api/lembur/$id'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'tanggal': formatDateForApi(tanggal),
  //       'jam_mulai': formatTime(jamMulai),
  //       'jam_selesai': formatTime(jamSelesai),
  //       'deskripsi': deskripsi,
  //     }),
  //   );

  //   final responseBody = json.decode(response.body);
  //   print("RESPON API: $responseBody");

  //   return {
  //     'success': response.statusCode == 200,
  //     'message': responseBody['message'] ?? 'Gagal mengedit lembur',
  //   };
  // }

  // // Hapus lembur
  // static Future<Map<String, dynamic>> deleteLembur(int id) async {
  //   final token = await _getToken();
  //   if (token == null)
  //     throw Exception('Token tidak ditemukan. Harap login ulang.');

  //   final response = await http.delete(
  //     Uri.parse('${ApiConfig.baseUrl}/api/lembur/$id'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //     },
  //   );

  //   final body = json.decode(response.body);

  //   return {
  //     'message': body['message'] ??
  //         (response.statusCode == 200
  //             ? 'Tugas berhasil dihapus'
  //             : 'Gagal menghapus tugas'),
  //   };
  // }

  // Fungsi menyetuji lembur
  static Future<String?> approveLembur(int id) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/lembur/$id/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      // print('Gagal menyetujui cuti: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  // Fungsi menolak lembur
  static Future<String?> declineLembur(int id, String catatanPenolakan) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/lembur/$id/decline'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'catatan_penolakan': catatanPenolakan,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseData['message'] ?? "Lembur berhasil ditolak";
    } else {
      // print('❌ Gagal menolak lembur: ${response.statusCode} ${response.body}');
      return responseData['message'] ?? "Gagal menolak lembur";
    }
  }
}

// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:convert';
// import 'package:intl/intl.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CutiService {
  // Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch cuti
  static Future<List<CutiModel>> fetchCuti() async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/cuti'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List cutiList = jsonData['data'];
      return cutiList.map((json) => CutiModel.fromJson(json)).toList();
    } else {
      // print('Gagal fetch cuti: ${response.statusCode} ${response.body}');
      throw Exception('Gagal memuat data cuti');
    }
  }

// Tambah cuti
  static Future<Map<String, dynamic>> createCuti({
    required String nama,
    required String tipeCuti,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    try {
      final formattedMulai = DateFormat('dd / MM / yyyy')
          .parse(tanggalMulai)
          .toIso8601String()
          .split('T')[0];
      final formattedSelesai = DateFormat('dd / MM / yyyy')
          .parse(tanggalSelesai)
          .toIso8601String()
          .split('T')[0];

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/cuti'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama': nama,
          'tipe_cuti': tipeCuti,
          'tanggal_mulai': formattedMulai,
          'tanggal_selesai': formattedSelesai,
          'alasan': alasan,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cuti berhasil diajukan',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengajukan cuti',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message':
            'Format tanggal tidak valid: $tanggalMulai - $tanggalSelesai',
      };
    }
  }

  // // Edit cuti
  // static Future<Map<String, dynamic>> editCuti({
  //   required int id,
  //   required String nama,
  //   required String tipeCuti,
  //   required String tanggalMulai,
  //   required String tanggalSelesai,
  //   required String alasan,
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

  //   final requestBody = {
  //     'nama': nama,
  //     'tipe_cuti': tipeCuti,
  //     'tanggal_mulai': formatDateForApi(tanggalMulai),
  //     'tanggal_selesai': formatDateForApi(tanggalSelesai),
  //     'alasan': alasan,
  //   };

  //   // Debug: lihat data yang dikirim
  //   print("DATA KIRIM: $requestBody");

  //   final response = await http.put(
  //     Uri.parse('${ApiConfig.baseUrl}/api/cuti/$id'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(requestBody),
  //   );

  //   final responseBody = json.decode(response.body);
  //   print("RESPON API: $responseBody");

  //   return {
  //     'success': response.statusCode == 200,
  //     'message': responseBody['message'] ?? 'Gagal update tugas',
  //   };
  // }

  // // Hapus cuti
  // static Future<Map<String, dynamic>> deleteCuti(int id) async {
  //   final token = await _getToken();
  //   if (token == null)
  //     throw Exception('Token tidak ditemukan. Harap login ulang.');

  //   final response = await http.delete(
  //     Uri.parse('${ApiConfig.baseUrl}/api/cuti/$id'),
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

  // Approve cuti
  static Future<String?> approveCuti(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/cuti/$id/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseData['message'];
    } else {
      final errorMessage = responseData['message'] ?? 'Terjadi kesalahan';
      return Future.error(errorMessage);
    }
  }

  // Decline cuti
  static Future<String?> declineCuti(int id, String catatanPenolakan) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/cuti/$id/decline'),
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
      return responseData['message'] ?? "Cuti berhasil ditolak";
    } else {
      // print('❌ Gagal menolak cuti: ${response.statusCode} ${response.body}');
      return responseData['message'] ?? "Gagal menolak cuti";
    }
  }
}

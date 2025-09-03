import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PengingatService {
  /// Ambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Fetch semua pengingat
  static Future<List<ReminderData>> fetchPengingat() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/pengingat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];

      return dataList.map((e) => ReminderData.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data pengingat: ${response.statusCode}');
    }
  }

  // /// Tambah pengingat baru
  // static Future<ReminderData> createPengingat(ReminderData reminder) async {
  //   final token = await getToken();
  //   if (token == null) throw Exception('Token tidak ditemukan');

  //   final response = await http.post(
  //     Uri.parse('${ApiConfig.baseUrl}/api/pengingat'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode(reminder.toJson()), // pastikan ReminderData punya toJson()
  //   );

  //   if (response.statusCode == 201) {
  //     final jsonData = json.decode(response.body)['data'];
  //     return ReminderData.fromJson(jsonData);
  //   } else {
  //     throw Exception('Gagal menambahkan pengingat: ${response.statusCode}');
  //   }
  // }

  /// Update pengingat
  static Future<void> updatePengingat(int id, String newStatus) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/pengingat/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status: ${response.statusCode}');
    }
  }


  /// Hapus pengingat
  static Future<void> deletePengingat(int id) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/pengingat/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pengingat: ${response.statusCode}');
    }
  }
}

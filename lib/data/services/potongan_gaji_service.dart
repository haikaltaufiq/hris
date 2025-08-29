import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PotonganGajiService {
  // Ambil token dari local storage
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ Fetch semua potongan gaji
  static Future<List<PotonganGajiModel>> fetchPotonganGaji() async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/potongan_gaji'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List data = jsonData['data'];
      return data.map((e) => PotonganGajiModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal fetch potongan gaji: ${response.body}');
    }
  }

  // ✅ Tambah potongan gaji
  static Future<PotonganGajiModel> createPotonganGaji(
      PotonganGajiModel potongan) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/potongan_gaji'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nama_potongan': potongan.namaPotongan,
        'persen': potongan.nominal,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return PotonganGajiModel.fromJson(jsonData['data']);
    } else {
      final jsonData = json.decode(response.body);
      final msg = jsonData['message'] ?? response.body;
      throw Exception('Gagal membuat potongan gaji: $msg');
    }
  }

  // Update potongan gaji
  static Future<Map<String, dynamic>> updatePotonganGaji(
      PotonganGajiModel potongan) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/potongan_gaji/${potongan.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nama_potongan': potongan.namaPotongan,
        'persen': potongan.nominal,
      }),
    );

    final jsonData = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": jsonData['message'] ?? "Potongan gaji berhasil diupdate",
        "data": PotonganGajiModel.fromJson(jsonData['data']),
      };
    } else {
      return {
        "success": false,
        "message": jsonData['message'] ?? "Gagal update potongan gaji",
      };
    }
  }

  // Hapus potongan gaji
  static Future<bool> deletePotonganGaji(int id) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan. Harap login ulang.');

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/potongan_gaji/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}

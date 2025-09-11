import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/fitur_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['data']);
      final prefs = await SharedPreferences.getInstance();

      // Simpan token dan data user
      await prefs.setString('token', data['token']);
      await prefs.setInt('id', user.id);
      await prefs.setString('nama', user.nama);
      await prefs.setString('email', user.email);
      await prefs.setString('npwp', user.npwp ?? '');
      await prefs.setString('bpjs_kesehatan', user.bpjsKesehatan ?? '');
      await prefs.setString('bpjs_ketenagakerjaan', user.bpjsKetenagakerjaan ?? '');
      await prefs.setString('jenis_kelamin', user.jenisKelamin);
      await prefs.setString('status_pernikahan', user.statusPernikahan);

      // Konversi gajiPokok ke double jika ada, fallback 0
      await prefs.setDouble(
        'gaji_pokok',
        double.tryParse(user.gajiPokok ?? '0') ?? 0,
      );

      // Cek null untuk jabatan
      await prefs.setString('jabatan', user.jabatan?.namaJabatan ?? '');
      await prefs.setString('departemen', user.departemen.namaDepartemen);
      await prefs.setString('peran', user.peran.namaPeran);
      await prefs.setString('fitur', jsonEncode(user.peran.fitur.map((f) => f.toJson()).toList()));

      return {
        'success': true,
        'token': data['token'],
        'user': user,
        'message': data['message'],
      };
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'],
      };
    }
  }

  // Update email
  Future<Map<String, dynamic>> updateEmail(
      String newEmail, String oldPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': newEmail,
        'old_password': oldPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await prefs.setString('email', data['data']['email']);

      return {
        'success': true,
        'message': data['message'],
        'data': data['data']
      };
    } else {
      return {
        'success': false,
        'message': data['message'],
        'errors': data['errors'] ?? {}
      };
    }
  }

  // Ambil fitur dari SharedPreferences
  Future<List<Fitur>> getFitur() async {
    final prefs = await SharedPreferences.getInstance();
    final fiturString = prefs.getString('fitur');
    if (fiturString == null) return [];

    final List<dynamic> decoded = jsonDecode(fiturString);
    return decoded.map((f) => Fitur.fromJson(f)).toList();
  }

  

  // ✅ Logout: hapus semua data user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // lebih aman, hapus semua
  }

  // ✅ Ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ Ambil nama user
  Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama');
  }

  // ✅ Ambil peran user
  Future<String?> getPeran() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('peran');
  }

  // ✅ Ambil semua data user
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('id'),
      'nama': prefs.getString('nama'),
      'email': prefs.getString('email'),
      'npwp': prefs.getString('npwp'),
      'bpjs_kesehatan': prefs.getString('bpjs_kesehatan'),
      'bpjs_ketenagakerjaan': prefs.getString('bpjs_ketenagakerjaan'),
      'jenis_kelamin': prefs.getString('jenis_kelamin'),
      'status_pernikahan': prefs.getString('status_pernikahan'),
      'gaji_pokok': prefs.getDouble('gaji_pokok'),
      'jabatan': prefs.getString('jabatan'),
      'departemen': prefs.getString('departemen'),
      'peran': prefs.getString('peran'),
      'token': prefs.getString('token'),
    };
  }
}

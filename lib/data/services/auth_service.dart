import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/fitur_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // helper ambil device info lengkap
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      return {
        "device_id": "web_browser",
        "device_model": "web",
        "device_manufacturer": "web",
        "device_version": "unknown",
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "device_id": androidInfo.id,
        "device_model": androidInfo.model,
        "device_manufacturer": androidInfo.manufacturer,
        "device_version": "Android ${androidInfo.version.release}",
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "device_id": iosInfo.identifierForVendor ?? "unknown_ios",
        "device_model": iosInfo.utsname.machine,
        "device_manufacturer": "Apple",
        "device_version": iosInfo.systemVersion,
      };
    } else {
      return {
        "device_id": "unknown_device",
        "device_model": "unknown",
        "device_manufacturer": "unknown",
        "device_version": "unknown",
      };
    }
  }

  // login dengan email, password, dan device_id
  Future<Map<String, dynamic>> login(String email, String password) async {
    final deviceInfo = await _getDeviceInfo();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
              'device_id': deviceInfo["device_id"] ?? 'unknown_device',
              'device_model': deviceInfo["device_model"] ?? 'unknown_model',
              'device_manufacturer':
                  deviceInfo["device_manufacturer"] ?? 'unknown_manufacturer',
              'device_version':
                  deviceInfo["device_version"] ?? 'unknown_version',
              'platform': kIsWeb ? 'web' : 'apk',
            }),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data['data']);
        final prefs = await SharedPreferences.getInstance();

        // simpan token & data user
        await prefs.setString('token', data['token']);
        await prefs.setInt('id', user.id);
        await prefs.setString('nama', user.nama);
        await prefs.setString('email', user.email);
        await prefs.setString('npwp', user.npwp ?? '');
        await prefs.setString('bpjs_kesehatan', user.bpjsKesehatan ?? '');
        await prefs.setString(
            'bpjs_ketenagakerjaan', user.bpjsKetenagakerjaan ?? '');
        await prefs.setString('jenis_kelamin', user.jenisKelamin);
        await prefs.setString('status_pernikahan', user.statusPernikahan);
        await prefs.setDouble(
            'gaji_per_hari', double.tryParse(user.gajiPokok ?? '0') ?? 0);
        await prefs.setString('jabatan', user.jabatan?.namaJabatan ?? '');
        await prefs.setString('departemen', user.departemen.namaDepartemen);
        await prefs.setString('peran', user.peran.namaPeran);
        await prefs.setString('fitur',
            jsonEncode(user.peran.fitur.map((f) => f.toJson()).toList()));
        await prefs.setBool('onboarding', data['onboarding'] ?? false);

        return {
          'success': true,
          'token': data['token'],
          'user': user,
          'onboarding': data['onboarding'] ?? false,
          'message': data['message'],
        };
      } else {
        // tangani error API dengan jelas
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login gagal',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
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

  // Cek user dari token (persist login pakai /me)
  Future<Map<String, dynamic>> me() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan'};
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['data']);

        // update data di SharedPreferences biar sinkron
        await prefs.setInt('id', user.id);
        await prefs.setString('nama', user.nama);
        await prefs.setString('email', user.email);
        await prefs.setString('peran', user.peran.namaPeran);

        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal ambil data user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // ganti password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal ganti password',
        'errors': data['errors'] ?? {}
      };
    }
  }

  // Logout hapus token di backend & clear prefs
  Future<Map<String, dynamic>> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      await prefs.clear();
      return {'success': true, 'message': 'Sudah logout (local only)'};
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await prefs.clear();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': 'Logout gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil nama user
  Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama');
  }

  // Ambil peran user
  Future<String?> getPeran() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('peran');
  }

  // Ambil semua data user
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
      'gaji_per_hari': prefs.getDouble('gaji_per_hari'),
      'jabatan': prefs.getString('jabatan'),
      'departemen': prefs.getString('departemen'),
      'peran': prefs.getString('peran'),
      'token': prefs.getString('token'),
    };
  }
}

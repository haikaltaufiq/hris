import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';
import 'package:hr/data/models/user_model.dart';

class TrackingService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Update lokasi user
  static Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/tracking/update');

    debugPrint('🚀 Kirim lokasi ke backend');
    debugPrint('LAT: $latitude, LNG: $longitude');
    
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('❌ Error: ${response.body}');
      throw Exception('Gagal update lokasi');
    }
    
    debugPrint('✅ Lokasi berhasil diupdate');
    debugPrint('📨 Response: ${response.body}');
  }

  /// ✅ PERBAIKAN: Ambil data tracking dengan struktur response yang benar
  static Future<List<UserModel>> getTrackingUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/tracking');
    
    debugPrint('🔍 Fetching tracking data...');
    
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      debugPrint('📦 Response structure: ${jsonResponse.keys}');
      
      // ✅ Backend mengirim { "status": "success", "data": [...], "summary": {...} }
      if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
        final List usersData = jsonResponse['data'];
        final summary = jsonResponse['summary'];
        
        debugPrint('📊 Summary - Total: ${summary['total']}, Aktif: ${summary['aktif']}, Tidak Aktif: ${summary['tidak_aktif']}');
        
        return usersData.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception('Format response tidak sesuai');
      }
    } else {
      debugPrint('❌ Error ${response.statusCode}: ${response.body}');
      throw Exception('Gagal ambil data tracking');
    }
  }

  /// 🆕 TAMBAHAN: Get filtered users (opsional, jika ingin filter di backend)
  static Future<List<UserModel>> getFilteredUsers(String status) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/tracking/filtered?status=$status');
    
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
        final List usersData = jsonResponse['data'];
        return usersData.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception('Format response tidak sesuai');
      }
    } else {
      throw Exception('Gagal ambil data tracking');
    }
  }

  /// 🆕 TAMBAHAN: Get summary saja (untuk info card)
  static Future<Map<String, int>> getTrackingSummary() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/tracking');
    
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['status'] == 'success' && jsonResponse['summary'] != null) {
        final summary = jsonResponse['summary'];
        return {
          'total': summary['total'] ?? 0,
          'aktif': summary['aktif'] ?? 0,
          'tidak_aktif': summary['tidak_aktif'] ?? 0,
        };
      }
    }
    
    return {'total': 0, 'aktif': 0, 'tidak_aktif': 0};
  }
}
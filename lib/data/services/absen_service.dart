// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsenService {
  /// Ambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Helper: generate header request
  static Future<Map<String, String>> _getHeaders(
      {bool jsonType = false}) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    if (jsonType) headers['Content-Type'] = 'application/json';

    return headers;
  }

  /// Fetch daftar absensi
  static Future<List<AbsenModel>> fetchAbsensi() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/absensi'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data'];
      return dataList.map((json) => AbsenModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data absensi: ${response.statusCode}');
    }
  }

  /// Check-in (support Mobile + Web)
  static Future<Map<String, dynamic>> checkin({
    required double lat,
    required double lng,
    required String checkinDate,
    required String checkinTime,
    required String videoPath,
    Uint8List? videoBytes,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/absensi/checkin');
    final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

    request.fields['lat'] = lat.toString();
    request.fields['lng'] = lng.toString();
    request.fields['checkin_date'] = checkinDate;
    request.fields['checkin_time'] = checkinTime;

    try {
      if (kIsWeb) {
        // Web → pakai base64 fallback
        if (videoBytes != null) {
          return await _checkinFallbackBase64(
            lat: lat,
            lng: lng,
            checkinDate: checkinDate,
            checkinTime: checkinTime,
            videoBytes: videoBytes,
          );
        } else {
          throw Exception('Video bytes diperlukan untuk platform web');
        }
      } else {
        // Mobile (Android/iOS)
        final videoFile = await http.MultipartFile.fromPath(
          'video_user',
          videoPath,
          contentType: MediaType('video', 'mp4'),
        );
        request.files.add(videoFile);
      }

      // print(
      //     "Checkin lat=$lat lng=$lng date=$checkinDate time=$checkinTime path=$videoPath");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final responseBody = json.decode(response.body);
        return {
          'success': responseBody['status'] ?? false,
          'message': responseBody['message'] ?? 'Terjadi kesalahan',
          'data': responseBody['data'] ?? {},
        };
      }

      return {
        'success': false,
        'message': 'Server mengembalikan non-JSON response',
        'data': {},
      };
    } catch (e) {
      // Fallback ke base64 kalau web gagal
      if (kIsWeb && videoBytes != null) {
        return await _checkinFallbackBase64(
          lat: lat,
          lng: lng,
          checkinDate: checkinDate,
          checkinTime: checkinTime,
          videoBytes: videoBytes,
        );
      }
      throw Exception('Error uploading video: $e');
    }
  }

  /// Check-in fallback (Web) → kirim video base64
  static Future<Map<String, dynamic>> _checkinFallbackBase64({
    required double lat,
    required double lng,
    required String checkinDate,
    required String checkinTime,
    required Uint8List videoBytes,
  }) async {
    final headers = await _getHeaders(jsonType: true);
    final videoBase64 = base64Encode(videoBytes);

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/absensi/checkin'),
      headers: headers,
      body: json.encode({
        'lat': lat,
        'lng': lng,
        'checkin_date': checkinDate,
        'checkin_time': checkinTime,
        'video_base64': videoBase64,
      }),
    );

    final responseBody = json.decode(response.body);
    return {
      'success':
          response.statusCode == 200 && (responseBody['status'] ?? false),
      'message': responseBody['message'] ?? 'Gagal check-in',
      'data': responseBody['data'] ?? {},
    };
  }

  /// Check-out
  static Future<Map<String, dynamic>> checkout({
    required double lat,
    required double lng,
    required String checkoutDate,
    required String checkoutTime,
  }) async {
    final headers = await _getHeaders(jsonType: true);

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/absensi/checkout'),
      headers: headers,
      body: json.encode({
        'lat': lat,
        'lng': lng,
        'checkout_date': checkoutDate,
        'checkout_time': checkoutTime,
      }),
    );

    final responseBody = json.decode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': responseBody['message'] ?? 'Gagal check-out',
      'data': responseBody['data'],
    };
  }
}

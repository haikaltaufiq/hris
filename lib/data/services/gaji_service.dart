import 'dart:convert';
import 'dart:io';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // hanya untuk web
// import 'gaji_model.dart';

class GajiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch gaji
  static Future<List<GajiUser>> fetchGaji() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/gaji'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List users = data['data'];
      return users.map((u) => GajiUser.fromJson(u)).toList();
    } else {
      throw Exception("Gagal mengambil data gaji");
    }
  }

  // Update status gaji
  static Future<void> updateStatus(int id, String status) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/gaji/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(
          "Gagal update status: ${body['message'] ?? response.body}");
    }
  }

  // Fetch available periods (bulan & tahun)
  static Future<List<Map<String, dynamic>>> getAvailablePeriods() async {
    final token = await getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final uri = Uri.parse("${ApiConfig.baseUrl}/api/gaji/periods");
    final response = await http.get(uri, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => {
        "bulan": e["bulan"],
        "tahun": e["tahun"],
      }).toList();
    } else {
      throw Exception("Gagal mengambil periode gaji");
    }
  }


  // Export gaji ke Excel dan simpan di storage
  static Future<void> exportGaji({required int bulan, required int tahun}) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Harap login ulang.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/gaji/export?bulan=$bulan&tahun=$tahun');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    });

    if (response.statusCode == 200) {
      final fileName = 'Laporan_HR_${bulan}_${tahun}.xlsx';

      if (kIsWeb) {
        // 👉 Untuk Web → buat link download
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        // final anchor = html.AnchorElement(href: url)
        //   ..setAttribute("download", fileName)
        //   ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // 👉 Untuk Android/iOS/Desktop → simpan file lokal
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        await OpenFilex.open(file.path);
      }
    } else {
      throw Exception('Gagal export gaji: ${response.statusCode}');
    }
  }

}

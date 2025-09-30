import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
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
}

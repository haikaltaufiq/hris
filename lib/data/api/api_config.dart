import 'package:http/http.dart' as http;

class ApiConfig {
  static const String publicUrl = "https://27.112.70.84";
  static const String privateUrl = "https://192.168.20.52";

  static String? _cachedBaseUrl;

  static Future<String> baseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    const timeout = Duration(seconds: 2);

    try {
      final res =
          await http.get(Uri.parse('$publicUrl/api/ping')).timeout(timeout);

      if (res.statusCode == 200) {
        _cachedBaseUrl = publicUrl;
        return _cachedBaseUrl!;
      }
    } catch (_) {
      // public down
    }

    _cachedBaseUrl = privateUrl;
    return _cachedBaseUrl!;
  }
}

//HP -> http (error self-signed certificate)
//Web -> https (ga error tapi warning saja self-signed certificate)

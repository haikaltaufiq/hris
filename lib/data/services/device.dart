import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

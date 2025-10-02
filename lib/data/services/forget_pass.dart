import 'dart:convert';
import 'package:hr/data/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:hr/data/models/forget_password_model.dart';

class ForgetPasswordService {
  static Future<ForgetPasswordResponse> sendResetLink(ForgetPasswordRequest request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/forgot-password');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    return ForgetPasswordResponse.fromJson(data);
  }
}

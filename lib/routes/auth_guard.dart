import 'package:flutter/material.dart';
import 'package:hr/data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isChecking = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;

  Future<void> init() async {
    _isChecking = true;
    notifyListeners();

    final authService = AuthService();
    final token = await authService.getToken();

    // cukup cek token ada atau enggak
    _isAuthenticated = token != null && token.isNotEmpty;

    _isChecking = false;
    notifyListeners();
  }

  Future<void> login(String token) async {
    final authService = AuthService();
    await authService.getToken(); // ini sebenarnya opsional
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final authService = AuthService();
    await authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}

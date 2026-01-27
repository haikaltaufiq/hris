import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get currentMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    AppColors.isDarkMode = _isDarkMode; //  sync ke AppColors
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    AppColors.isDarkMode = value; //  sync ke AppColors
    notifyListeners();
  }
}

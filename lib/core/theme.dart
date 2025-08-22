import 'package:flutter/material.dart';

// Warna dasar untuk dark mode
const _primaryDark = Color(0xFF1F1F1F);
const _secondaryDark = Color(0xFF3F3F3F);
const _bgDark = Color(0xFF121212);
const _putihDark = Color(0xFFE0E0E0);
const _hitamDark = Color(0xFF050505);
const _greenDark = Color(0xFF247F43);
const _redDark = Color(0xFF802F2F);

// Warna untuk light mode (kamu sesuaikan)
const _primaryLight = Color(0xFFFFFFFF);
const _secondaryLight = Color(0xFFF0F0F0);
const _bgLight = Color.fromARGB(255, 235, 235, 235);
const _putihLight = Color(0xFF000000);
const _hitamLight = Color(0xFF050505);
const _greenLight = Color(0xFF1CCA56);
const _redLight = Color(0xFFC82626);

// Sebuah kelas yang menyimpan status theme saat ini
class AppColors {
  static bool isDarkMode = true; // default, nanti bisa diubah

  static Color get primary => isDarkMode ? _primaryDark : _primaryLight;
  static Color get secondary => isDarkMode ? _secondaryDark : _secondaryLight;
  static Color get bg => isDarkMode ? _bgDark : _bgLight;
  static Color get putih => isDarkMode ? _putihDark : _putihLight;
  static Color get hitam => isDarkMode ? _hitamDark : _hitamLight;
  static Color get green => isDarkMode ? _greenDark : _greenLight;
  static Color get red => isDarkMode ? _redDark : _redLight;

  static const Color yellow = Color(0xFFFAD53F);
  static const Color blue = Color(0xFF13214B);
  static const Color grey = Color(0xFF2D3038);
}

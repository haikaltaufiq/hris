import 'dart:ui';

// Warna dasar untuk dark mode
const _primaryDark = Color(0xFF1F1F1F); // for Card
const _secondaryDark = Color(0xFF3F3F3F); // Button / Card
const _latar3Dark = Color.fromARGB(255, 22, 22, 22); // Button / Card
const _bgDark = Color(0xFF121212); // Background
const _putihDark = Color(0xFFE0E0E0); // for Text
const _hitamDark = Color(0xFF050505);
const _greenDark = Color.fromARGB(255, 80, 163, 83); // for Success
const _redDark = Color(0xFF802F2F); // for Error

// Warna untuk light mode
const _primaryLight = Color(0xFFFFFFFF);
const _secondaryLight = Color(0xFFF0F0F0);
const _latar3Light = Color(0xFFF0F0F0);

const _bgLight = Color(0xFFF7F7F7);
const _putihLight = Color(0xFF000000);
const _hitamLight = Color(0xFF050505);
const _greenLight = Color(0xFF4EDD53);
const _redLight = Color(0xFFC82626);

// Sebuah kelas yang menyimpan status theme saat ini
class AppColors {
  static bool isDarkMode = false; // default, nanti bisa diubah

  static Color get primary => isDarkMode
      ? _primaryDark
      : _primaryLight; // utama (Card / komponen2 utama lain yang mencolok)
  static Color get secondary => isDarkMode
      ? _secondaryDark
      : _secondaryLight; // sekunder (Button / komponen2 sekunder lain)
  static Color get latar3 => isDarkMode
      ? _latar3Dark
      : _latar3Light; // latar belakang tingkat 3 (desain latar di card gaji dll yang lebih ringan dari primary)
  static Color get bg =>
      isDarkMode ? _bgDark : _bgLight; // latar belakang aplikasi
  static Color get putih => isDarkMode ? _putihDark : _putihLight; // untuk teks
  static Color get hitam =>
      isDarkMode ? _hitamDark : _hitamLight; // untuk warna hitam
  static Color get green =>
      isDarkMode ? _greenDark : _greenLight; // untuk warna hijau (success)
  static Color get red =>
      isDarkMode ? _redDark : _redLight; // untuk warna merah (error)

  static const Color yellow = Color(0xFFFAD53F); // warna kuning tetap (warning)
  static const Color blue = Color(0xFF13214B); // warna biru tetap
  static const Color grey = Color(0xFF2D3038); // warna abu-abu tetap
}

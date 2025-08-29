// language_provider.dart
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('id');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  // opsional: set language langsung
  void setLanguage(String code) {
    _locale = Locale(code);
    notifyListeners();
  }
}

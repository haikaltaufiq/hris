import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isIndonesian = true;

  bool get isIndonesian => _isIndonesian;
  bool get isEnglish => !_isIndonesian;

  void toggleLanguage(bool value) {
    _isIndonesian = value;
    notifyListeners();
  }

  void toggleEnglish() => toggleLanguage(isEnglish);
  void toggleIndonesian() => toggleLanguage(isIndonesian);
}

extension LanguageContext on BuildContext {
  bool get isIndonesian => watch<LanguageProvider>().isIndonesian;
  bool get isEnglish => watch<LanguageProvider>().isEnglish;
}

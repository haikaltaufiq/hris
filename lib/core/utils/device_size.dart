import 'package:flutter/foundation.dart'; // buat cek kIsWeb
import 'package:flutter/material.dart';

extension DeviceExtension on BuildContext {
  // ukuran layar
  Size get deviceSize => MediaQuery.of(this).size;
  double get deviceWidth => deviceSize.width;
  double get deviceHeight => deviceSize.height;

  // device category - FIXED LOGIC
  bool get isWeb => kIsWeb; // true kalau running di web

  // Mobile: screen width < 600 (regardless of platform)
  bool get isMobile => deviceWidth < 600;

  // Tablet: screen width between 600-1024 (regardless of platform)
  bool get isTablet => deviceWidth >= 600 && deviceWidth < 1024;

  // Desktop: screen width >= 1024 (regardless of platform)
  bool get isDesktop => deviceWidth >= 1024;

  // Alternative: if you want to distinguish native vs web
  bool get isNativeMobile => !kIsWeb && deviceWidth < 600;
  bool get isWebMobile => kIsWeb && deviceWidth < 600;
  bool get isNativeTablet => !kIsWeb && deviceWidth >= 600 && deviceWidth < 1024;
  bool get isWebTablet => kIsWeb && deviceWidth >= 600 && deviceWidth < 1024;
  bool get isNativeDesktop => !kIsWeb && deviceWidth >= 1024;
  bool get isWebDesktop => kIsWeb && deviceWidth >= 1024;

  // scaling factor (base 375 iPhone X misalnya)
  double scale(double value) => value * deviceWidth / 375;

  // font scaling
  double font(double size) => scale(size);

  // padding scaling
  EdgeInsets padding(double value) => EdgeInsets.all(scale(value));
  EdgeInsets symmetricPadding({double h = 0, double v = 0}) => EdgeInsets.symmetric(horizontal: scale(h), vertical: scale(v));
}

// app_sizes.dart
import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';

class AppSizes {
  // base font size
  static const double fontBase = 14;

  // font sizes (static baseline)
  static const double fontSmall = 12;
  static const double fontMedium = 14;
  static const double fontLarge = 18;
  static const double fontXL = 24;

  // padding baseline
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  // margin baseline
  static const double marginS = 8;
  static const double marginM = 16;
  static const double marginL = 24;

  // responsive padding pakai device extension
  static double responsivePadding(BuildContext context) {
    if (context.isMobile) return paddingM;
    if (context.isTablet) return paddingL;
    return paddingXL; // desktop
  }

  // responsive font size pakai device extension
  static double responsiveFont(BuildContext context) {
    if (context.isMobile) return fontMedium;
    if (context.isTablet) return fontLarge;
    return fontXL; // desktop
  }

  /// ========== FIX BAGIAN SCALING ==========
  /// scaling font pakai extension, tapi aman (ada clamp biar ga overflow)
  static double scaleFont(BuildContext context, double size) {
    final scaled = context.font(size);
    return scaled.clamp(size * 0.8, size * 1.5);
  }

  /// scaling padding pakai extension dengan clamp
  static EdgeInsets scalePadding(BuildContext context, double value) {
    final scaled = context.scale(value).clamp(value * 0.8, value * 1.5);
    return EdgeInsets.all(scaled);
  }

  static EdgeInsets scaleSymmetric(
    BuildContext context, {
    double h = 0,
    double v = 0,
  }) {
    final scaledH = context.scale(h).clamp(h * 0.8, h * 1.5);
    final scaledV = context.scale(v).clamp(v * 0.8, v * 1.5);
    return EdgeInsets.symmetric(horizontal: scaledH, vertical: scaledV);
  }
}

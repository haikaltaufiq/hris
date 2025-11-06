import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FeatureGuard extends StatefulWidget {
  final dynamic requiredFeature;
  final Widget child;

  const FeatureGuard({
    super.key,
    required this.requiredFeature,
    required this.child,
  });

  @override
  State<FeatureGuard> createState() => _FeatureGuardState();
}

class _FeatureGuardState extends State<FeatureGuard> {
  @override
  Widget build(BuildContext context) {
    final required = widget.requiredFeature;

    bool hasAccess = false;

    if (required is String) {
      hasAccess = FeatureAccess.has(required);
    } else if (required is List<String>) {
      hasAccess = required.every(FeatureAccess.has);
    } else {
      hasAccess = false;
    }

    return hasAccess ? widget.child : const SizedBox.shrink();
  }
}

class FeatureAccess {
  static List<String> _fitur = [];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final fiturString = prefs.getString('fitur');
    if (fiturString != null) {
      final List decoded = jsonDecode(fiturString);
      _fitur = decoded.map((f) => f['nama_fitur'].toString()).toList();
    } else {
      _fitur = [];
    }
  }

  static void reset() {
    _fitur = [];
  }

  static List<String> get fitur => _fitur;
  // lebih aman
  static Future<void> setFeatures(List<dynamic>? fiturFromBackend) async {
    final prefs = await SharedPreferences.getInstance();

    if (fiturFromBackend == null) {
      _fitur = [];
      await prefs.remove('fitur');
      return;
    }

    _fitur = fiturFromBackend
        .map((f) => (f is Map && f['nama_fitur'] != null)
            ? f['nama_fitur'].toString()
            : null)
        .whereType<String>()
        .toList();

    // simpan juga ke shared preferences
    await prefs.setString('fitur', jsonEncode(fiturFromBackend));
    // debugPrint('✅ FeatureAccess updated: $_fitur');
  }

  static bool has(String requiredFeature) {
    return _fitur.contains(requiredFeature);
  }

  // ✅ Tambahin ini
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    _fitur = [];
    await prefs.remove('fitur');
  }
}

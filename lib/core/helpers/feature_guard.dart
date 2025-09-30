import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FeatureGuard extends StatefulWidget {
  final String requiredFeature;
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
    final hasAccess = FeatureAccess.has(widget.requiredFeature);
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

  static bool has(String requiredFeature) {
    return _fitur.contains(requiredFeature);
  }
}

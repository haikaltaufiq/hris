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
  bool _isLoading = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _loadFitur();
  }

  Future<void> _loadFitur() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fiturString = prefs.getString('fitur');

      if (fiturString != null) {
        final List<dynamic> decoded = jsonDecode(fiturString);
        final userFitur =
            decoded.map((f) => f['nama_fitur'].toString()).toList();

        // Check if user has access to required feature
        _hasAccess = userFitur.contains(widget.requiredFeature);
      }
    } catch (e) {
      debugPrint('Error loading fitur: $e');
      _hasAccess = false;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink(); // Atau bisa return const SizedBox() aja
    }

    // Return widget jika punya akses, return kosong jika tidak
    return _hasAccess ? widget.child : const SizedBox.shrink();
  }
}

// Extension untuk kemudahan penggunaan
extension FeatureGuardExtension on Widget {
  Widget guardedBy(String requiredFeature) {
    return FeatureGuard(
      requiredFeature: requiredFeature,
      child: this,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:provider/provider.dart';
import '../../data/services/location_tracker.dart';

class AuthListener extends StatefulWidget {
  final Widget child;

  const AuthListener({super.key, required this.child});

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener> {
  bool? _previousLoginState;

  void _checkAuthState(bool isLoggedIn) {
    // Skip jika state belum berubah
    if (_previousLoginState == isLoggedIn) return;

    _previousLoginState = isLoggedIn;

    if (isLoggedIn) {
      LocationTracker.start();
      debugPrint('📍 Location tracking STARTED');
    } else {
      LocationTracker.stop();
      debugPrint('🛑 Location tracking STOPPED');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        _checkAuthState(userProvider.isLoggedIn);
        return widget.child;
      },
    );
  }
}

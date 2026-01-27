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
  bool _trackingStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = context.watch<UserProvider>();

    debugPrint(
      '🔄 AuthListener rebuild | isLoggedIn=${userProvider.isLoggedIn}',
    );

    // ✅ USER LOGIN → START TRACKING
    if (userProvider.isLoggedIn && !_trackingStarted) {
      LocationTracker.start();
      _trackingStarted = true;
      debugPrint('📍 Location tracking STARTED');
    }

    // 🚪 USER LOGOUT → STOP TRACKING
    if (!userProvider.isLoggedIn && _trackingStarted) {
      LocationTracker.stop();
      _trackingStarted = false;
      debugPrint('🛑 Location tracking STOPPED');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

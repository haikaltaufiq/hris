import 'package:flutter/material.dart';
import 'package:hr/data/services/auth_service.dart';
import 'package:hr/features/auth/login_page.dart';
import 'package:hr/features/landing/landing_page.dart';
import 'package:hr/features/landing/mobile/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr/core/utils/device_size.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final auth = AuthService();
    final result = await auth.me();

    if (!mounted) return;

    if (result['success'] != true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

    setState(() {
      _loggedIn = result['success'] == true;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loggedIn) {
      if (context.isNativeMobile) {
        return const LandingPageMobile();
      } else {
        return const LandingPage();
      }
    } else {
      return const LoginPage();
    }
  }
}

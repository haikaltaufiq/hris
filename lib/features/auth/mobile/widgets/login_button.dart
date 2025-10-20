import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/auth_service.dart';
import 'package:hr/data/services/pengaturan_service.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LoginButton extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final void Function(String) onError;

  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onError,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;
  bool _isHovering = false;
  bool _isPressed = false;

  Future<void> _handleLogin(BuildContext context) async {
    final email = widget.emailController.text.trim();
    final password = widget.passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      widget.onError("Email dan password wajib diisi");
      return;
    }
    if (!_isValidEmail(email)) {
      widget.onError("Format email tidak valid");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      final result = await auth.login(email, password);

      if (result['success'] == true && result['token'] != null) {
        final token = result['token'];
        final box = await Hive.openBox('user');
        await box.put('token', token);

        // user sudah berupa UserModel, bukan Map
        final user = result['user'] as UserModel?;
        final userRole = user?.peran;

        // ambil fitur dari peran
        final fiturList = userRole?.fitur.map((f) => f.toJson()).toList() ?? [];

        await FeatureAccess.setFeatures(fiturList);
        await FeatureAccess.init();

        final pengaturanService = PengaturanService();

        try {
          await pengaturanService.getPengaturan(token);
          if (context.mounted) {
            Provider.of<ThemeProvider>(context, listen: false);
            Provider.of<LanguageProvider>(context, listen: false);
          }
        } catch (e) {
          print('Gagal fetch pengaturan: $e');
        }

        NotificationHelper.showTopNotification(
          context,
          result['message'] ?? "Login berhasil",
          isSuccess: true,
        );
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.dashboardMobile);
        }
      } else {
        final backendMessage = result['message'];

        // Kalau backend mengirim message spesifik, pakai langsung
        // Kalau null atau message umum terkait email/password, pakai mapping
        final errorMessage = (backendMessage == null ||
                backendMessage.toLowerCase().contains('password') ||
                backendMessage.toLowerCase().contains('email') ||
                backendMessage.toLowerCase().contains('invalid credentials'))
            ? _mapErrorMessage(backendMessage)
            : backendMessage;

        widget.onError(errorMessage);
      }
    } on FormatException {
      widget.onError("Terjadi kesalahan pada server. Coba lagi nanti.");
    } on TimeoutException {
      widget.onError("Request timeout. Periksa koneksi internet.");
    } catch (_) {
      widget.onError("Check your internet connection");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  String _mapErrorMessage(String? raw) {
    if (raw == null) return "Terjadi kesalahan";

    final lower = raw.toLowerCase();
    if (lower.contains("password")) return "Email atau Password salah";
    if (lower.contains("email")) return "Email tidak ditemukan";
    if (lower.contains("invalid credentials")) {
      return "Email atau Password salah";
    }
    return "Terjadi kesalahan. Coba lagi nanti.";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: _isLoading ? null : () => _handleLogin(context),
      onHover: (hovering) {
        if (!context.isNativeMobile) {
          setState(() => _isHovering = hovering);
        }
      },
      onHighlightChanged: (pressed) {
        if (context.isNativeMobile) {
          setState(() => _isPressed = pressed);
        }
      },
      child: AnimatedScale(
        scale: (_isHovering || _isPressed) && !_isLoading ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: screenWidth * 0.85,
          height: 60,
          decoration: BoxDecoration(
            color: _isLoading
                ? const Color.fromARGB(255, 12, 21, 48)
                : (_isHovering || _isPressed
                    ? const Color.fromARGB(255, 7, 12, 27)
                    : const Color.fromRGBO(19, 33, 75, 1)),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Log in',
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 14,
                      color: const Color.fromRGBO(224, 224, 224, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

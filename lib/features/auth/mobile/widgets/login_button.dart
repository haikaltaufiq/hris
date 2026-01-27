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
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
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

  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

  Future<void> _handleLogin(BuildContext context) async {
    final email = widget.emailController.text.trim();
    final password = widget.passwordController.text;

    if (!_validateInputs(email, password)) return;

    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      final result = await auth.login(email, password);

      if (result['success'] == true && result['token'] != null) {
        final token = result['token'];
        final user = result['user'] as UserModel?;

        if (user != null && context.mounted) {
          // Execute settings load and user data save in parallel
          await Future.wait([
            _loadAndApplySettings(context, token),
            _saveUserData(token, user, auth),
          ]);

          // ==================================================
          // 🔥 INI YANG WAJIB ADA (KUNCI SEMUANYA)
          // ==================================================
          context.read<UserProvider>().setUser(user);

          final message =
              context.isIndonesian ? "Login berhasil" : "Login success";

          NotificationHelper.showTopNotification(
            context,
            result['message'] ?? message,
            isSuccess: true,
          );

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.dashboardMobile,
          );
        } else {
          widget.onError("Terjadi kesalahan pada data user");
        }
      } else {
        _handleLoginError(result['message']);
      }
    } on FormatException {
      widget.onError("Terjadi kesalahan pada server. Coba lagi nanti.");
    } on TimeoutException {
      widget.onError("Request timeout. Periksa koneksi internet.");
    } catch (e) {
      widget.onError("Check your internet connection");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  bool _validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      widget.onError("Email dan password wajib diisi");
      return false;
    }
    if (!_emailRegex.hasMatch(email)) {
      widget.onError("Format email tidak valid");
      return false;
    }
    return true;
  }

  /// Save user data with optimized batch operations
  Future<void> _saveUserData(
      String token, UserModel user, AuthService auth) async {
    final userBox = await Hive.openBox('user');

    // Prepare feature list
    final fiturList = user.peran?.fitur.map((f) => f.toJson()).toList();

    // Execute Hive write and feature setup in parallel
    await Future.wait([
      userBox.putAll({
        'token': token,
        'id': user.id,
      }),
      FeatureAccess.setFeatures(fiturList),
    ]);

    // Initialize features after data is set
    await FeatureAccess.init();

    // Non-blocking email save
    auth.saveEmail(user.email);
  }

  /// Load settings with timeout protection
  Future<void> _loadAndApplySettings(BuildContext context, String token) async {
    try {
      final pengaturanService = PengaturanService();

      // Add timeout to prevent long blocking
      final pengaturan = await pengaturanService.getPengaturan(token).timeout(
            const Duration(seconds: 3),
            onTimeout: () => {'tema': 'terang', 'bahasa': 'indonesia'},
          );

      final tema = pengaturan['tema'] ?? 'terang';
      final bahasa = pengaturan['bahasa'] ?? 'indonesia';

      if (context.mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        themeProvider.setDarkMode(tema == 'gelap');
        langProvider.toggleLanguage(bahasa == 'indonesia');
      }
    } catch (e) {
      // Use default settings on error
    }
  }

  void _handleLoginError(String? backendMessage) {
    final errorMessage =
        (backendMessage == null || _isCredentialError(backendMessage))
            ? _mapErrorMessage(backendMessage)
            : backendMessage;

    widget.onError(errorMessage);
  }

  bool _isCredentialError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('password') ||
        lower.contains('email') ||
        lower.contains('invalid credentials');
  }

  String _mapErrorMessage(String? raw) {
    if (raw == null) return "Terjadi kesalahan";

    final lower = raw.toLowerCase();
    if (lower.contains("password") || lower.contains("invalid credentials")) {
      return "Email atau Password salah";
    }
    if (lower.contains("email")) return "Email tidak ditemukan";

    return "Terjadi kesalahan. Coba lagi nanti.";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNativeMobile = context.isNativeMobile;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: _isLoading ? null : () => _handleLogin(context),
      onHover: !isNativeMobile
          ? (hovering) {
              setState(() => _isHovering = hovering);
            }
          : null,
      onHighlightChanged: isNativeMobile
          ? (pressed) {
              setState(() => _isPressed = pressed);
            }
          : null,
      child: AnimatedScale(
        scale: (_isHovering || _isPressed) && !_isLoading ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: screenWidth * 0.85,
          height: 60,
          decoration: BoxDecoration(
            color: _getButtonColor(),
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

  Color _getButtonColor() {
    if (_isLoading) return const Color.fromARGB(255, 12, 21, 48);
    if (_isHovering || _isPressed) return const Color.fromARGB(255, 7, 12, 27);
    return const Color.fromRGBO(19, 33, 75, 1);
  }
}

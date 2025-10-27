import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/data/services/pengaturan_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage>
    with TickerProviderStateMixin {
  late AnimationController _themeAnimationController;
  late AnimationController _langAnimationController;

  late PengaturanService _service;
  String token = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = PengaturanService();

    _themeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _langAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initTokenAndLoad();
  }

  Future<void> _initTokenAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Get providers
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final langProvider =
          Provider.of<LanguageProvider>(context, listen: false);

      // Set initial animation values from current provider state
      _themeAnimationController.value = themeProvider.isDarkMode ? 1.0 : 0.0;
      _langAnimationController.value = langProvider.isIndonesian ? 1.0 : 0.0;

      // Load settings from database
      final pengaturan = await _service.getPengaturan(token);
      final tema = pengaturan['tema'] ?? 'terang';
      final bahasa = pengaturan['bahasa'] ?? 'indonesia';

      print('✅ Pengaturan Page - Loaded: tema=$tema, bahasa=$bahasa');

      final isDark = tema == 'gelap';
      final isID = bahasa == 'indonesia';

      // Sync to providers
      themeProvider.setDarkMode(isDark);
      langProvider.toggleLanguage(isID);

      // Update animation controllers
      if (mounted) {
        setState(() {
          _themeAnimationController.value = isDark ? 1.0 : 0.0;
          _langAnimationController.value = isID ? 1.0 : 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Pengaturan Page - Error loading: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _themeAnimationController.dispose();
    _langAnimationController.dispose();
    super.dispose();
  }

  void _toggleTheme() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final newDark = !themeProvider.isDarkMode;

    themeProvider.setDarkMode(newDark);

    // Update animation
    newDark
        ? _themeAnimationController.forward()
        : _themeAnimationController.reverse();

    // Update backend
    try {
      final langProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      await _service.updatePengaturan(
        token: token,
        tema: newDark ? 'gelap' : 'terang',
        bahasa: langProvider.isIndonesian ? 'indonesia' : 'inggris',
      );
      print('✅ Tema updated to: ${newDark ? "gelap" : "terang"}');
    } catch (e) {
      print('❌ Gagal update tema: $e');
      // Revert on error
      themeProvider.setDarkMode(!newDark);
      newDark
          ? _themeAnimationController.reverse()
          : _themeAnimationController.forward();
    }
  }

  void _toggleLanguage() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final newLang = !langProvider.isIndonesian;

    langProvider.toggleLanguage(newLang);

    // Update animation
    newLang
        ? _langAnimationController.forward()
        : _langAnimationController.reverse();

    // Update backend
    try {
      await _service.updatePengaturan(
        token: token,
        tema: themeProvider.isDarkMode ? 'gelap' : 'terang',
        bahasa: newLang ? 'indonesia' : 'inggris',
      );
      print('✅ Bahasa updated to: ${newLang ? "indonesia" : "inggris"}');
    } catch (e) {
      print('❌ Gagal update bahasa: $e');
      // Revert on error
      langProvider.toggleLanguage(!newLang);
      newLang
          ? _langAnimationController.reverse()
          : _langAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

    final isDark = themeProvider.isDarkMode;
    final isIndonesian = langProvider.isIndonesian;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: LoadingWidget(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          if (MediaQuery.of(context).size.width < 600)
            Header(title: isIndonesian ? "Pengaturan" : "Settings"),

          // Theme Card
          Card(
            color: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIndonesian ? 'Penampilan' : 'Appearance',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.putih,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isIndonesian
                        ? "Pilih preferensi anda"
                        : 'Choose your preferred theme',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.putih.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIndonesian ? "Tema" : 'Theme',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.putih,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isDark
                                  ? isIndonesian
                                      ? 'Tema gelap diterapkan'
                                      : 'Dark theme enabled'
                                  : isIndonesian
                                      ? 'Tema terang diterapkan'
                                      : 'Light theme enabled',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.putih.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleTheme,
                        child: AnimatedBuilder(
                          animation: _themeAnimationController,
                          builder: (context, child) {
                            return Container(
                              width: 60,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Color.lerp(
                                  AppColors.secondary.withOpacity(0.3),
                                  AppColors.secondary,
                                  _themeAnimationController.value,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Opacity(
                                          opacity: 1 -
                                              _themeAnimationController.value,
                                          child: Icon(
                                            FontAwesomeIcons.sun,
                                            size: 14,
                                            color: AppColors.putih
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        Opacity(
                                          opacity:
                                              _themeAnimationController.value,
                                          child: Icon(
                                            FontAwesomeIcons.moon,
                                            size: 12,
                                            color: AppColors.putih
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    left: isDark ? 32 : 4,
                                    top: 4,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.putih,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isDark
                                            ? FontAwesomeIcons.moon
                                            : FontAwesomeIcons.sun,
                                        size: 12,
                                        color: isDark
                                            ? const Color(0xFF4A5568)
                                            : Colors.orange.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIndonesian ? 'Bahasa' : 'Language',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.putih,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isIndonesian
                                  ? 'Bahasa Indonesia aktif'
                                  : 'English enabled',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.putih.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleLanguage,
                        child: AnimatedBuilder(
                          animation: _langAnimationController,
                          builder: (context, child) {
                            return Container(
                              width: 60,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Color.lerp(
                                  AppColors.secondary.withOpacity(0.3),
                                  AppColors.secondary,
                                  _langAnimationController.value,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Opacity(
                                          opacity: 1 -
                                              _langAnimationController.value,
                                          child: const Text(
                                            'EN',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Opacity(
                                          opacity:
                                              _langAnimationController.value,
                                          child: const Text(
                                            'ID',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    left: isIndonesian ? 32 : 4,
                                    top: 4,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.putih,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          isIndonesian ? 'ID' : 'EN',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isIndonesian
                                                ? Colors.red.shade600
                                                : Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

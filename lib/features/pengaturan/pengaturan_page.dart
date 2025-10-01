import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:provider/provider.dart';

class PengaturanPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const PengaturanPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage>
    with TickerProviderStateMixin {
  late bool isSwitched;
  late AnimationController _themeAnimationController;
  late Animation<double> _themeAnimation;
  late AnimationController _langAnimationController;

  @override
  void initState() {
    super.initState();

    // Theme
    isSwitched = widget.isDarkMode;
    _themeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _themeAnimation = CurvedAnimation(
        parent: _themeAnimationController, curve: Curves.easeInOut);

    if (isSwitched) {
      _themeAnimationController.value = 1.0;
    }

    // Language
    _langAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langProvider = Provider.of<LanguageProvider>(context);
    _langAnimationController.value = langProvider.isIndonesian ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _themeAnimationController.dispose();
    _langAnimationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      isSwitched = !isSwitched;
    });

    if (isSwitched) {
      _themeAnimationController.forward();
    } else {
      _themeAnimationController.reverse();
    }

    widget.toggleTheme();
  }

  void _toggleLanguage() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final newValue = !langProvider.isIndonesian;

    if (newValue) {
      _langAnimationController.forward();
    } else {
      _langAnimationController.reverse();
    }

    langProvider.toggleLanguage(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isIndonesian = langProvider.isIndonesian;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          if (context.isMobile) const Header(title: "Pengaturan"),

          // Theme Card
          Card(
            color: AppColors.primary,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isIndonesian ? 'Penampilan' : 'Appearance',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.putih)),
                  const SizedBox(height: 8),
                  Text(
                      isIndonesian
                          ? "Pilih preferensi anda"
                          : 'Choose your preferred theme',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.putih.withOpacity(0.7))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isIndonesian ? "Tema" : 'Theme',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.putih)),
                            const SizedBox(height: 4),
                            Text(
                                isSwitched
                                    ? isIndonesian
                                        ? 'Tema gelap diterapkan'
                                        : 'Dark theme enabled'
                                    : isIndonesian
                                        ? 'Tema terang diterapkan'
                                        : 'Light theme enabled',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.putih.withOpacity(0.6))),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleTheme,
                        child: AnimatedBuilder(
                          animation: _themeAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 60,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Color.lerp(
                                    AppColors.secondary.withOpacity(0.3),
                                    AppColors.secondary,
                                    _themeAnimation.value),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Opacity(
                                            opacity: 1 - _themeAnimation.value,
                                            child: Icon(FontAwesomeIcons.sun,
                                                size: 14,
                                                color: AppColors.putih
                                                    .withOpacity(0.6))),
                                        Opacity(
                                            opacity: _themeAnimation.value,
                                            child: Icon(FontAwesomeIcons.moon,
                                                size: 12,
                                                color: AppColors.putih
                                                    .withOpacity(0.8))),
                                      ],
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    left: isSwitched ? 32 : 4,
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
                                              offset: const Offset(0, 2)),
                                        ],
                                      ),
                                      child: Icon(
                                        isSwitched
                                            ? FontAwesomeIcons.moon
                                            : FontAwesomeIcons.sun,
                                        size: 12,
                                        color: isSwitched
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isIndonesian ? 'Bahasa' : 'Language',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.putih)),
                            const SizedBox(height: 4),
                            Text(
                                isIndonesian
                                    ? 'Bahasa Indonesia aktif'
                                    : 'English enabled',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.putih.withOpacity(0.6))),
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
                                    _langAnimationController.value),
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
                                            child: const Text('EN',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white))),
                                        Opacity(
                                            opacity:
                                                _langAnimationController.value,
                                            child: const Text('ID',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white))),
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
                                              offset: const Offset(0, 2)),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(isIndonesian ? 'ID' : 'EN',
                                            style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isIndonesian
                                                    ? Colors.red.shade600
                                                    : Colors.blue.shade700)),
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

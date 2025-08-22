import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';

class PengaturanTheme extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const PengaturanTheme({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<PengaturanTheme> createState() => _PengaturanThemeState();
}

class _PengaturanThemeState extends State<PengaturanTheme>
    with SingleTickerProviderStateMixin {
  late bool isSwitched;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    isSwitched = widget.isDarkMode;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set initial animation value after everything is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSwitched) {
        _animationController.value = 1.0;
      } else {
        _animationController.value = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PengaturanTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      setState(() {
        isSwitched = widget.isDarkMode;
      });
    }
  }

  void _toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
    });

    if (value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    widget.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Theme Settings',
          style: TextStyle(
            color: AppColors.putih,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.putih,
          onPressed: () => Navigator.of(context).pop(isSwitched),
        ),
        iconTheme: IconThemeData(color: AppColors.putih),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Theme Selection Card
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
                      'Appearance',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.putih,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your preferred theme',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.putih.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Custom Theme Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.putih,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSwitched
                                    ? 'Dark theme enabled'
                                    : 'Light theme enabled',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.putih.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cool Animated Switch
                        GestureDetector(
                          onTap: () => _toggleSwitch(!isSwitched),
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Container(
                                width: 60,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Color.lerp(
                                    AppColors.secondary.withOpacity(0.3),
                                    AppColors.secondary,
                                    _animation.value,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Track background with icons
                                    Positioned.fill(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Sun icon (left side)
                                          Opacity(
                                            opacity: 1 - _animation.value,
                                            child: Icon(
                                              FontAwesomeIcons.sun,
                                              size: 14,
                                              color: AppColors.putih
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          // Moon icon (right side)
                                          Opacity(
                                            opacity: _animation.value,
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
                                    // Animated thumb
                                    AnimatedPositioned(
                                      duration:
                                          const Duration(milliseconds: 300),
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
                                              offset: const Offset(0, 2),
                                            ),
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Theme Preview Card
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            FontAwesomeIcons.eye,
                            size: 16,
                            color: AppColors.putih,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Preview',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.putih,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mini preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.putih.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSwitched
                                ? FontAwesomeIcons.moon
                                : FontAwesomeIcons.sun,
                            color: AppColors.putih.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSwitched ? 'Dark Theme' : 'Light Theme',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.putih,
                                ),
                              ),
                              Text(
                                isSwitched
                                    ? 'Easy on the eyes'
                                    : 'Bright and clear',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.putih.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

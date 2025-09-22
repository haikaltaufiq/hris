// widgets/landing_content.dart
import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/landing/widgets/section/about.dart';
import 'package:hr/features/landing/widgets/section/features.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:lottie/lottie.dart';
import '../../../core/utils/device_size.dart';

class LandingContent extends StatelessWidget {
  final Map<String, GlobalKey> sectionKeys;
  const LandingContent({super.key, required this.sectionKeys});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            key: sectionKeys['home'], // Gunakan key dari parent
            child: HeroSection(sectionKeys: sectionKeys), // Pass lagi ke child
          ),

          // Responsive gap antara Hero dan About
          SizedBox(
            height: context.isMobile
                ? 60
                : context.isTablet
                    ? 80
                    : 100,
          ),

          // About Section
          Container(
            key: sectionKeys['about'],
            child: AboutSection(sectionKeys: sectionKeys),
          ),

          // Responsive gap antara About dan Features
          SizedBox(
            height: context.isMobile
                ? 60
                : context.isTablet
                    ? 80
                    : 100,
          ),

          // Features Section
          Container(
            key: sectionKeys['features'],
            child: FeaturesSection(sectionKeys: sectionKeys),
          ),

          // Bottom padding untuk section terakhir
          SizedBox(
            height: context.isMobile
                ? 40
                : context.isTablet
                    ? 60
                    : 80,
          ),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  final Map<String, GlobalKey> sectionKeys;
  const HeroSection({
    super.key,
    required this.sectionKeys,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 16 : 48,
        vertical: context.isMobile ? 0 : 100,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: context.isMobile || context.isTablet
              ? _buildMobileLayout(context, l10n)
              : _buildDesktopLayout(context, l10n),
        ),
      ),
    );
  }

  // Layout untuk Mobile & Tablet - Stack vertikal
  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: context.isMobile ? 0 : 20),
        // Content section
        _buildContentSection(context, l10n),
        if (context.isTablet) const SizedBox(height: 40),
        if (context.isMobile) const SizedBox(height: 30),
        // Image placeholder untuk nanti
        _buildImagePlaceholder(context),
        SizedBox(height: context.isMobile ? 120 : 0),
      ],
    );
  }

  // Layout untuk Desktop - Side by side
  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        // Content section - ambil flex lebih banyak
        Expanded(
          flex: 3,
          child: _buildContentSection(context, l10n),
        ),
        const SizedBox(width: 60),
        // Image section - ambil flex lebih sedikit
        Expanded(
          flex: 2,
          child: _buildImagePlaceholder(context),
        ),
      ],
    );
  }

  // Content section (title, subtitle, button)
  Widget _buildContentSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: context.isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.isMobile ? 100 : 0),
        _buildTitle(context, l10n),
        const SizedBox(height: 16),
        _buildSubtitle(context, l10n),
        const SizedBox(height: 30),
        _buildCTAButtons(context),
      ],
    );
  }

  // Image placeholder - siap untuk gambar nanti
  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.isMobile
          ? 250
          : context.isTablet
              ? 300
              : 400,
      child: Center(
        child: Lottie.asset(
          'assets/lottie/data.json',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: context.isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Human Resource',
          textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: context.isMobile
                ? 28
                : context.isTablet
                    ? 40
                    : 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
            height: 1.1,
            letterSpacing: -1.5,
          ),
        ),
        Text(
          'Information System',
          textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: context.isMobile
                ? 28
                : context.isTablet
                    ? 40
                    : 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
            height: 1.1,
            letterSpacing: -1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, AppLocalizations l10n) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context.isMobile
            ? double.infinity
            : context.isTablet
                ? 400
                : 500,
      ),
      child: Text(
        l10n.landingDescription,
        textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: context.isMobile
              ? 16
              : context.isTablet
                  ? 18
                  : 22,
          fontWeight: FontWeight.w600,
          color: Colors.black.withOpacity(0.6),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    if (context.isMobile) {
      return SizedBox(
        width: double.infinity,
        child: _buildPrimaryButton(context),
      );
    }

    return Row(
      mainAxisAlignment:
          context.isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        _buildPrimaryButton(context),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.putih,
        padding: EdgeInsets.symmetric(
          horizontal: context.isMobile ? 30 : 60,
          vertical: context.isMobile ? 18 : 22,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 0,
        minimumSize: context.isMobile
            ? const Size(double.infinity, 50)
            : const Size(140, 50),
      ),
      child: Text(
        'Get Started',
        style: TextStyle(
          fontSize: context.isMobile ? 14 : 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

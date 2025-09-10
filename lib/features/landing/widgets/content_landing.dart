// widgets/landing_content.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import '../../../core/utils/device_size.dart';

class LandingContent extends StatelessWidget {
  const LandingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: const Column(
        children: [
          HeroSection(),
          AboutSection(),
          FeaturesSection(),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 24 : 48,
        vertical: context.isMobile ? 60 : 100,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            const SizedBox(height: 92),
            _buildTitle(context, l10n),
            const SizedBox(height: 6),
            _buildSubtitle(context, l10n),
            const SizedBox(height: 30),
            _buildCTAButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          'Human Resource',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
            height: context.isMobile ? 0.0 : 0.5,
            letterSpacing: -1.5,
          ),
        ),
        Text(
          'Information System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
            height: context.isMobile ? 1.5 : 0,
            letterSpacing: -1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: 500,
      child: Text(
        l10n.landingDescription,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: Colors.black.withOpacity(0.6),
          height: context.isMobile ? 1.5 : 1.0,
        ),
      ),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    if (context.isMobile) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: _buildPrimaryButton(context),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildSecondaryButton(context),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPrimaryButton(context),
        const SizedBox(width: 16),
        _buildSecondaryButton(context),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.login);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.putih,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        'Get Started',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return OutlinedButton(
      onPressed: () {
        scrollController.animateTo(
          690, // ✅ offset tujuan
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
        side: BorderSide(
          color: AppColors.blue,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Learn More',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.blue,
        ),
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 24 : 48,
        vertical: context.isMobile ? 100 : 30,
      ),
      child: Container(
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildSectionHeader(context),
            const SizedBox(height: 30),
            SizedBox(width: 1250, child: _buildAboutGrid(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
        ),
        Text(
          'About',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            'HRIS (Human Resources Information System) adalah sistem terintegrasi yang mengelola data karyawan, proses HR, dan operasional bisnis secara efisien untuk meningkatkan produktivitas organisasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black.withOpacity(0.6),
              height: context.isMobile ? 1.5 : 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutGrid(BuildContext context) {
    final aboutItems = [
      {
        'icon': FontAwesomeIcons.users,
        'title': 'Manajemen Karyawan',
        'description':
            'Kelola data lengkap karyawan dari rekrutmen hingga pensiun dengan sistem yang terintegrasi dan aman',
      },
      {
        'icon': FontAwesomeIcons.chartLine,
        'title': 'Laporan & Analisis',
        'description':
            'Dapatkan insight mendalam tentang performa karyawan dan operasional HR melalui dashboard analytics',
      },
      {
        'icon': FontAwesomeIcons.shield,
        'title': 'Keamanan Data',
        'description':
            'Sistem keamanan berlapis dengan enkripsi data dan kontrol akses untuk melindungi informasi sensitif',
      },
      {
        'icon': FontAwesomeIcons.cloud,
        'title': 'Cloud Based',
        'description':
            'Akses sistem kapan saja dan dimana saja dengan infrastruktur cloud yang handal dan scalable',
      },
    ];

    if (context.isMobile) {
      return Column(
        children: aboutItems
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12), // jarak rapet
                  child: _buildAboutCard(
                    context,
                    item['icon'] as IconData,
                    item['title'] as String,
                    item['description'] as String,
                  ),
                ))
            .toList(),
      );
    }

    // Desktop / Web grid 2x2, jarak rapet
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: aboutItems.take(2).map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8), // jarak antar card rapet
                child: _buildAboutCard(
                  context,
                  item['icon'] as IconData,
                  item['title'] as String,
                  item['description'] as String,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12), // jarak antar row rapet
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: aboutItems.skip(2).take(2).map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildAboutCard(
                  context,
                  item['icon'] as IconData,
                  item['title'] as String,
                  item['description'] as String,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      // Padding internal card dikurangi atau di-set minimal
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 24 : 48,
        vertical: context.isMobile ? 60 : 190,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildSectionHeader(context),
            const SizedBox(height: 15),
            SizedBox(width: 1250, child: _buildFeaturesGrid(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Key Features',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
            height: 1.5,
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Discover the powerful features that make HRIS the perfect solution for your business needs',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      {
        'icon': FontAwesomeIcons.clipboardCheck,
        'title': 'Attendance Management',
        'description':
            'Track employee attendance with real-time monitoring and automated reporting system',
      },
      {
        'icon': FontAwesomeIcons.calendarCheck,
        'title': 'Leave Management',
        'description':
            'Streamline leave requests, approvals, and balance tracking in one centralized platform',
      },
      {
        'icon': FontAwesomeIcons.clock,
        'title': 'Overtime Tracking',
        'description':
            'Monitor and calculate overtime hours with automatic compensation calculations',
      },
      {
        'icon': FontAwesomeIcons.clipboardList,
        'title': 'Task Management',
        'description':
            'Organize, assign, and track tasks efficiently with integrated project management tools',
      },
      {
        'icon': FontAwesomeIcons.moneyBill,
        'title': 'Payroll',
        'description':
            'Automated payroll processing with tax calculations, deductions, and direct deposit integration',
      },
    ];

    if (context.isMobile) {
      return Column(
        children: features
            .map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _buildFeatureCard(
                    context,
                    feature['icon'] as IconData,
                    feature['title'] as String,
                    feature['description'] as String,
                  ),
                ))
            .toList(),
      );
    }

    // Desktop/Tablet layout - 3 cards in first row, 2 cards in second row
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: features
              .take(3)
              .map((feature) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildFeatureCard(
                        context,
                        feature['icon'] as IconData,
                        feature['title'] as String,
                        feature['description'] as String,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: features.skip(3).map((feature) {
            return Flexible(
              fit: FlexFit.loose, // biar ngikutin height konten
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildFeatureCard(
                  context,
                  feature['icon'] as IconData,
                  feature['title'] as String,
                  feature['description'] as String,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// widgets/landing_navbar.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import '../../../core/utils/device_size.dart';

class LandingNavbar extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, GlobalKey> sectionKeys;

  const LandingNavbar({
    super.key,
    required this.scrollController,
    required this.sectionKeys,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLogo(context),
            _buildNavigation(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => _scrollToSection('home'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.isMobile ? 28 : 32,
            height: context.isMobile ? 28 : 32,
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.building,
                size: context.isMobile ? 16 : 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (!context.isMobile || MediaQuery.of(context).size.width > 235)
            Text(
              'Human Resource',
              style: TextStyle(
                fontSize: context.isMobile ? 16 : 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context, AppLocalizations l10n) {
    if (context.isTablet || context.isMobile) {
      return IconButton(
        onPressed: () => _showMobileMenu(context, l10n),
        icon: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
        tooltip: 'Menu',
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildNavItems(context),
        const SizedBox(width: 24),
        _buildLoginButton(context, l10n),
      ],
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    final items = [
      {'name': 'Home', 'key': 'home'},
      {'name': 'About', 'key': 'about'},
      {'name': 'Features', 'key': 'features'},
      {'name': 'Contact', 'key': 'contact'},
    ];

    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(right: 32),
              child: InkWell(
                onTap: () => _scrollToSection(item['key'] as String),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }

  Widget _buildLoginButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.login);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: context.isMobile ? 16 : 24,
          vertical: context.isMobile ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        l10n.loginButton,
        style: TextStyle(
          fontSize: context.isMobile ? 12 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Navigation items
                ..._buildMobileNavItems(context),

                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: _buildMobileLoginButton(context, l10n),
                ),

                // Extra spacing for better UX
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMobileNavItems(BuildContext context) {
    final items = [
      {'name': 'Home', 'key': 'home', 'icon': Icons.home_outlined},
      {'name': 'About', 'key': 'about', 'icon': Icons.info_outline},
      {'name': 'Features', 'key': 'features', 'icon': Icons.star_outline},
      {
        'name': 'Contact',
        'key': 'contact',
        'icon': Icons.contact_mail_outlined
      },
    ];

    return items
        .map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Icon(
                  item['icon'] as IconData,
                  color: AppColors.blue,
                  size: 22,
                ),
                title: Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _scrollToSection(item['key'] as String);
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ))
        .toList();
  }

  Widget _buildMobileLoginButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRoutes.login);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.login, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.loginButton,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToSection(String sectionKey) {
    final key = sectionKeys[sectionKey];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.0, // Scroll to top of the section
      );
    }
  }
}

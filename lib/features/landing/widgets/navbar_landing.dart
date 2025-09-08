// widgets/landing_navbar.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import '../../../core/utils/device_size.dart';

class LandingNavbar extends StatelessWidget {
  final ScrollController scrollController;

  const LandingNavbar({
    super.key,
    required this.scrollController,
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
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.building,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'HRIS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context, AppLocalizations l10n) {
    if (context.isMobile) {
      return IconButton(
        onPressed: () => _showMobileMenu(context, l10n),
        icon: Icon(
          Icons.menu,
          color: Colors.black,
        ),
      );
    }

    return Row(
      children: [
        ..._buildNavItems(context),
        const SizedBox(width: 24),
        _buildLoginButton(context, l10n),
      ],
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    final items = [
      {'name': 'Home', 'offset': 0.0},
      {'name': 'About', 'offset': 690.0},
      {'name': 'Features', 'offset': 1530.0},
      {'name': 'Contact', 'offset': 2000.0},
    ];

    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(right: 32),
              child: InkWell(
                onTap: () => _scrollToSection(item['offset'] as double),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    item['name'] as String,
                    style: TextStyle(
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        l10n.loginButton,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ..._buildMobileNavItems(context),
            const SizedBox(width: double.infinity, height: 16),
            _buildLoginButton(context, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMobileNavItems(BuildContext context) {
    final items = [
      {'name': 'Home', 'offset': 0.0},
      {'name': 'About', 'offset': 800.0},
      {'name': 'Features', 'offset': 1200.0},
      {'name': 'Contact', 'offset': 2000.0},
    ];

    return items
        .map((item) => ListTile(
              title: Text(
                item['name'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(item['offset'] as double);
              },
            ))
        .toList();
  }

  void _scrollToSection(double offset) {
    scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }
}

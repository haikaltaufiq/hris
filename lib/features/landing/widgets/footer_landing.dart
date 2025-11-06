// widgets/landing_footer.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/device_size.dart';

class LandingFooter extends StatelessWidget {
  final Map<String, GlobalKey> sectionKeys;

  const LandingFooter({super.key, required this.sectionKeys});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      key: sectionKeys['contact'],
      width: double.infinity,
      color: AppColors.blue,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 24 : 48,
        vertical: 48,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            if (context.isDesktop) ...[
              _buildDesktopFooter(context),
            ] else ...[
              _buildMobileFooter(context),
            ],
            const SizedBox(height: 32),
            Divider(
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              '© 2025 HRIS. ${l10n.footerText}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildBrandColumn(context),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: _buildFooterColumn(
            context,
            'Product',
            [
              {'text': 'About Us', 'section': 'about'},
              {'text': 'Features', 'section': 'features'},
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: _buildFooterColumn(
            context,
            'Contact Us',
            [
              {'text': 'hris.ksi@kreatifsystem.com', 'section': null},
              {'text': '0778 214 0088', 'section': null},
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      children: [
        _buildBrandColumn(context),
        const SizedBox(height: 40),
        _buildMobileLinks(context),
      ],
    );
  }

  Widget _buildBrandColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: context.isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: context.isDesktop
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.building,
                  size: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Human Resource',
              style: TextStyle(
                fontSize: 20,
                letterSpacing: -0.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'Making HR management simple and efficient for modern businesses worldwide.',
            textAlign: context.isDesktop ? TextAlign.start : TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterColumn(
    BuildContext context,
    String title,
    List<Map<String, String?>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) {
          final text = item['text']!;
          final section = item['section'];
          IconData? icon;
          VoidCallback? onTapAction;

          if (text.contains('@')) {
            icon = Icons.email;
            onTapAction = () => _launchEmail(text);
          } else if (RegExp(r'^[0-9+ ]+$').hasMatch(text)) {
            icon = Icons.phone;
            onTapAction = () => _launchPhone(text);
          } else if (section != null) {
            onTapAction = () => _scrollToSection(section);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: onTapAction,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                      decoration: onTapAction != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMobileLinks(BuildContext context) {
    final links = [
      {'text': 'Features', 'section': 'features'},
      {'text': 'About Us', 'section': 'about'},
      {'text': 'Contact', 'section': 'contact'},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 16,
      children: links
          .map((link) => InkWell(
                onTap: () => _scrollToSection(link['section']!),
                child: Text(
                  link['text']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  /// Scroll to target section
  void _scrollToSection(String sectionKey) {
    final key = sectionKeys[sectionKey];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  /// Launch email client
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  /// Launch phone dialer
  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(' ', ''),
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

// widgets/landing_footer.dart
import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/l10n/app_localizations.dart';
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
              '© 2024 HRIS. ${l10n.footerText}',
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
        const SizedBox(width: 48),
        Expanded(
          child: _buildFooterColumn(
            context,
            'Product',
            ['Features', 'Pricing', 'Documentation', 'Support'],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: _buildFooterColumn(
            context,
            'Company',
            ['About Us', 'Careers', 'Contact', 'Blog'],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: _buildFooterColumn(
            context,
            'Contact Us',
            ['hris.ksi@kreatifsystem.com', '0778 214 0088'],
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
              child: Icon(
                Icons.business,
                size: 20,
                color: AppColors.blue,
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
    List<String> items,
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
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {},
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMobileLinks(BuildContext context) {
    final links = [
      'Features',
      'Pricing',
      'About Us',
      'Contact',
      'Privacy Policy',
      'Terms of Service'
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 16,
      children: links
          .map((link) => InkWell(
                onTap: () {},
                child: Text(
                  link,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(62, 255, 255, 255),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

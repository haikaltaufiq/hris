import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/core/theme/app_colors.dart';

class FeaturesSection extends StatelessWidget {
  final Map<String, GlobalKey> sectionKeys;

  const FeaturesSection({
    super.key,
    required this.sectionKeys,
  });

  // Data cards
  static final List<Map<String, dynamic>> aboutItems = [
    {
      'icon': FontAwesomeIcons.clipboardCheck,
      'title': 'Attendance ',
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 48,
            vertical: isMobile ? 20 : 40,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isMobile
                  ? _buildMobileLayout(context, isMobile, isTablet)
                  : _buildDesktopLayout(context, isMobile, isTablet),
            ),
          ),
        );
      },
    );
  }

  // Layout Mobile: stack di bawah
  Widget _buildMobileLayout(
      BuildContext context, bool isMobile, bool isTablet) {
    return Column(
      children: [
        _buildSectionHeader(context, isMobile, isTablet),
        const SizedBox(height: 30),
        _buildAboutSwiper(context, isMobile, isTablet),
      ],
    );
  }

  // Layout Desktop: side by side
  Widget _buildDesktopLayout(
      BuildContext context, bool isMobile, bool isTablet) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: _buildSectionHeader(context, isMobile, isTablet),
            ),
            const SizedBox(width: 60),
            Expanded(
              flex: 3,
              child: _buildAboutSwiper(context, isMobile, isTablet),
            ),
          ],
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  // Section Header
  Widget _buildSectionHeader(
      BuildContext context, bool isMobile, bool isTablet) {
    final theme = Theme.of(context);
    final headlineColor =
        theme.textTheme.headlineLarge?.color ?? Colors.black87;

    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile
                ? 28
                : isTablet
                    ? 40
                    : 48,
            fontWeight: FontWeight.bold,
            color: headlineColor,
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 800,
          ),
          child: Text(
            'HRIS (Human Resources Information System) provides an integrated approach to '
            'managing employee records, HR processes, and business operations, improving '
            'efficiency and productivity.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: isMobile
                  ? 16
                  : isTablet
                      ? 18
                      : 20,
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // Swiper cards
  Widget _buildAboutSwiper(BuildContext context, bool isMobile, bool isTablet) {
    final itemWidth = 450.0;
    final itemHeight = isMobile ? 200.0 : 240.0;

    return Column(
      children: [
        SizedBox(
          height: isMobile ? 0 : 100,
        ),
        SizedBox(
          height: isMobile
              ? 280
              : isTablet
                  ? 320
                  : 360,
          child: Center(
            child: CardSwiper(
              cardsCount: aboutItems.length,
              cardBuilder: (context, index, horizontalOffsetPercentage,
                  verticalOffsetPercentage) {
                final item = aboutItems[index];
                return Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: _buildAboutCard(
                      context,
                      item['icon'] as IconData,
                      item['title'] as String,
                      item['description'] as String,
                      isMobile,
                      isTablet,
                    ),
                  ),
                );
              },
              numberOfCardsDisplayed: isMobile ? 2 : 3,
              backCardOffset: const Offset(0, -40),
              scale: 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              duration: const Duration(milliseconds: 300),
              onEnd: () {
                debugPrint("Semua card sudah di-swipe");
              },
            ),
          ),
        ),
      ],
    );
  }

  // Card design
  // Card design
  Widget _buildAboutCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isMobile,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final headlineColor =
        theme.textTheme.headlineSmall?.color ?? Colors.black87;
    final bodyColor = theme.textTheme.bodyMedium?.color ?? Colors.black54;

    return _HoverCard(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 48 : 56,
                height: isMobile ? 48 : 56,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 18 : 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isMobile ? 16 : 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: headlineColor,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 15),
          Flexible(
            child: Text(
              description,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: bodyColor,
                height: 1.5,
              ),
              maxLines: isMobile ? 4 : 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const _HoverCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 16,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _hovering
            ? (Matrix4.identity()..translate(0, -6, 0))
            : Matrix4.identity(),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.15 : 0.1),
              blurRadius: _hovering ? 30 : 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

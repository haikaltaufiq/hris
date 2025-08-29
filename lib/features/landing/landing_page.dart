// landing_page.dart
import 'package:flutter/material.dart';
import 'package:hr/features/landing/widgets/content_landing.dart';
import 'package:hr/features/landing/widgets/footer_landing.dart';
import 'package:hr/features/landing/widgets/navbar_landing.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Fixed Navbar
          LandingNavbar(
            scrollController: _scrollController,
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  LandingContent(),
                  LandingFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

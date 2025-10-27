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
  late ScrollController _scrollController = ScrollController();
  late Map<String, GlobalKey> _sectionKeys;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _sectionKeys = {
      'home': GlobalKey(),
      'about': GlobalKey(),
      'features': GlobalKey(),
      'contact': GlobalKey(),
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Stack(
        children: [
          // // Background layer
          // Positioned.fill(
          //   child: LandingBackground(),
          // ),

          // Content layer
          Column(
            children: [
              LandingNavbar(
                scrollController: _scrollController,
                sectionKeys: _sectionKeys,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      LandingContent(
                        sectionKeys: _sectionKeys,
                      ),
                      LandingFooter(
                        sectionKeys: _sectionKeys,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

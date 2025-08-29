import 'package:flutter/material.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';

class WebPageGaji extends StatelessWidget {
  const WebPageGaji({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SearchingBar(
            controller: SearchController(),
            onFilter1Tap: () {},
          ),
        ],
      ),
    );
  }
}

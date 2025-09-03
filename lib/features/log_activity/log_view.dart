import 'package:flutter/material.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/log_activity/widgets/web_tabel_log.dart';

class LogActivity extends StatelessWidget {
  const LogActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
        child: ListView(
          children: [
            if (context.isMobile) Header(title: "Log Activity"),
            SearchingBar(
              controller: SearchController(),
              onFilter1Tap: () {},
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 5.0 : 26.0,
                vertical: 10.0,
              ),
              child: WebTabelLog(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/log_activity/web/web_page_log.dart';

class LogActivity extends StatelessWidget {
  const LogActivity({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      // return TaskMobile();
    }
    return WebPageLog();
  }
}

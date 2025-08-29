import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/gaji/web/web_page_gaji.dart';

class GajiPage extends StatelessWidget {
  const GajiPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      // return TaskMobile();
    }
    return WebPageGaji();
  }
}

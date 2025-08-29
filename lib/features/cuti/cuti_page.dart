import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/cuti/mobile/cuti_page.dart';
import 'package:hr/features/cuti/web/cuti_web_page.dart';

class CutiPage extends StatelessWidget {
  const CutiPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return CutiPageMobile();
    }
    return CutiWebPage();
  }
}

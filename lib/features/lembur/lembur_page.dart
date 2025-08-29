import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/lembur/mobile/lembur_mobile_page.dart';
import 'package:hr/features/lembur/web/page_web_lembur.dart';

class LemburPage extends StatelessWidget {
  const LemburPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return LemburMobile();
    }
    return LemburWebPage();
  }
}

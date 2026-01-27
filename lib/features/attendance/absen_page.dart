import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/attendance/mobile/absenMobile.dart';
import 'package:hr/features/attendance/web/absen_web_page.dart';

class AbsenPage extends StatelessWidget {
  const AbsenPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return AbsenMobile();
    }
    return AbsenWebPage();
  }
}

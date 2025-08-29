import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/jabatan/mobile/jabatan_page.dart';
import 'package:hr/features/jabatan/web/web_page.dart';

class JabatanPage extends StatelessWidget {
  const JabatanPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return JabatanPageMobile();
    }
    return WebPageJabatan();
  }
}

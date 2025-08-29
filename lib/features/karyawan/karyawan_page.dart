import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/karyawan/mobile/karyawan_page.dart';
import 'package:hr/features/karyawan/web/web_page_karyawan.dart';

class KaryawanPage extends StatelessWidget {
  const KaryawanPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return KaryawanMobile();
    }
    return WebPageKaryawan();
  }
}

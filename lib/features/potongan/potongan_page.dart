import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/potongan/mobile/potongan_page.dart';
import 'package:hr/features/potongan/web/web_page_potongan.dart';

class PotonganPage extends StatelessWidget {
  const PotonganPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return PotonganMobile();
    }
    return WebPagePotongan();
  }
}

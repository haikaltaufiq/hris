import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/peran/web/web_page_peran.dart';

class PeranPage extends StatelessWidget {
  const PeranPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      // return TaskMobile();
    }
    return WebPagePeran();
  }
}

import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/department/mobile/departemen_page.dart';
import 'package:hr/features/department/web/web_page_department.dart';

class DepartmentPage extends StatelessWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return DepartemenPageMobile();
    }
    return WebPageDepartment();
  }
}

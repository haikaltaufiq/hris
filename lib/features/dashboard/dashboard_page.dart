import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/dashboard/mobile/dashboard_page.dart';
import 'package:hr/features/dashboard/web/dashboard_web.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    initializeFCM();
  }

  Future<void> initializeFCM() async {
    // buka box user
    final userBox = await Hive.openBox('user');

    // ambil data user login dari Hive
    final token = userBox.get('token');
    final userId = userBox.get('id');

    if (userId == null || token == null) {
      // debugPrint("User belum login. Skip init FCM.");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Kondisi: kalau mobile -> langsung lempar ke DashboardMobile
    if (context.isMobile) {
      return DashboardMobile();
    }

    // ✅ Selain itu, tetap pake layout dashboard desktop yang ada
    return DashboardWeb();
  }
}

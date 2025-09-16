import 'package:flutter/material.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/danger/reset_db.dart';

class DangerPage extends StatefulWidget {
  const DangerPage({super.key});

  @override
  State<DangerPage> createState() => _DangerPageState();
}

class _DangerPageState extends State<DangerPage> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          if (context.isMobile)
            const Align(
              alignment: Alignment.bottomLeft,
              child: Header(title: "Danger"),
            ),
          SearchingBar(
            controller: searchController,
            onFilter1Tap: () {},
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ResetDb(),
          ),
        ]),
      ),
    );
  }
}

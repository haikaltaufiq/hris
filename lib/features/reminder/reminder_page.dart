import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/reminder/widget/remind_tabel.dart';
import 'package:hr/features/reminder/widget/remind_tabel_mobile.dart';
import 'package:hr/routes/app_routes.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: ListView(
              children: [
                if (context.isMobile) Header(title: "Reminder Page"),
                SearchingBar(controller: SearchController()),
                if (context.isMobile) RemindTabelMobile(),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: ReminderTileWeb(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.reminderAdd);
              },
              backgroundColor: AppColors.secondary,
              shape: const CircleBorder(),
              child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
            ),
          ),
        ],
      ),
    );
  }
}

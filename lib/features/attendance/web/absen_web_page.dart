import 'package:flutter/material.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/attendance/widget/absen_excel_export.dart';
import 'package:hr/features/attendance/widget/absen_web_tabel.dart';

class AbsenWebPage extends StatelessWidget {
  const AbsenWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SearchingBar(
            controller: SearchController(),
            onFilter1Tap: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: AbsenExcelExport(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AbsenTabelWeb(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/info_kantor/company_card.dart';

class InfoKantorPage extends StatefulWidget {
  const InfoKantorPage({super.key});

  @override
  State<InfoKantorPage> createState() => _InfoKantorPageState();
}

class _InfoKantorPageState extends State<InfoKantorPage> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          if (context.isMobile)
            Align(
              alignment: Alignment.bottomLeft,
              child: Header(
                  title: context.isIndonesian ? "Info Kantor" : 'Company Info'),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 4.0 : 30.0,
                vertical: context.isMobile ? 4.0 : 16.0),
            child: CompanyCard(),
          ),
        ]),
      ),
    );
  }
}

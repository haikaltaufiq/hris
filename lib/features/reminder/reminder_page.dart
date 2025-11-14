import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/sorting.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/pengingat_model.dart';
import 'package:hr/features/reminder/reminder_viewmodels.dart';
import 'package:hr/features/reminder/widget/remind_tabel.dart';
import 'package:hr/features/reminder/widget/remind_tabel_mobile.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  late final TextEditingController _searchController;
  List<ReminderData> reminders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Fetch data saat pertama kali load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PengingatViewModel>();
      if (provider.pengingatList.isEmpty) {
        provider.loadCacheFirst();
        provider.fetchPengingat();
      }
    });

    // Listen to search changes
    _searchController.addListener(() {
      context.read<PengingatViewModel>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                if (context.isMobile)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.putih,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      Header(
                          title: context.isIndonesian
                              ? 'Pengingat'
                              : "Reminder Page"),
                    ],
                  ),
                SearchingBar(
                  controller: _searchController,
                  onFilter1Tap: () async {
                    final provider = context.read<PengingatViewModel>();

                    final selected = await showSortDialog(
                      context: context,
                      title: context.isIndonesian
                          ? 'Urutkan Berdasarkan'
                          : 'Sort By',
                      currentValue: provider.currentSortField,
                      options: [
                        {
                          'value': 'terdekat',
                          'label': context.isIndonesian ? 'Terbaru' : 'Newest'
                        },
                        {
                          'value': 'terlama',
                          'label': context.isIndonesian ? 'Terlama' : 'Oldest'
                        },
                      ],
                    );

                    if (selected != null) {
                      provider.sortPengingat(selected);
                    }

                    if (selected != null) {
                      provider.sortPengingat(selected);
                    }
                  },
                ),
                if (context.isMobile) ...[
                  RemindTabelMobile(),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: ReminderTileWeb(),
                  ),
                ]
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(context, AppRoutes.reminderAdd);

                if (result == true) {
                  context.read<PengingatViewModel>().fetchPengingat();
                }
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

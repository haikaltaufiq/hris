import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/potongan/view_model/potongan_gaji_provider.dart';
import 'package:hr/features/potongan/web/web_tabel.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class WebPagePotongan extends StatefulWidget {
  const WebPagePotongan({super.key});

  @override
  State<WebPagePotongan> createState() => _WebPagePotonganState();
}

class _WebPagePotonganState extends State<WebPagePotongan> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PotonganGajiProvider>();
      if (provider.potonganList.isEmpty) {
        provider.loadCacheFirst();
        provider.fetchPotonganGaji();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final potonganProvider = context.watch<PotonganGajiProvider>();
    final displayedList = searchController.text.isEmpty
        ? potonganProvider.potonganList
        : potonganProvider.filteredPotonganGajiList;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SearchingBar(
                controller: searchController,
                onChanged: (value) {
                  potonganProvider.filterPotonganGaji(value);
                },
              ),
              if (potonganProvider.isLoading && displayedList.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: LoadingWidget()),
                )
              else if (potonganProvider.potonganList.isEmpty &&
                  !potonganProvider.isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 64,
                          color: AppColors.putih.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.isIndonesian
                              ? 'Belum ada Potongan'
                              : 'No deduction data avalable',
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.isIndonesian
                              ? 'Tap tombol + untuk menambah Potongan Gaji baru'
                              : 'Press + button to add new deduction',
                          style: TextStyle(
                            color: AppColors.putih.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Fixed: Remove ListView.builder and directly use PotonganTabel
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                  child: PotonganTabelWeb(
                    potonganList: displayedList,
                    onActionDone: () {
                      searchController.clear();
                    },
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.potonganForm,
                );
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

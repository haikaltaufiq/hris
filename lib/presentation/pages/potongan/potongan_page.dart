import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/potongan/potongan_form/potongan_form.dart';
import 'package:hr/presentation/pages/potongan/widget/potongan_tabel.dart';
import 'package:hr/provider/function/potongan_gaji_provider.dart';
import 'package:provider/provider.dart';

class PotonganPage extends StatefulWidget {
  const PotonganPage({super.key});

  @override
  State<PotonganPage> createState() => _PotonganPageState();
}

class _PotonganPageState extends State<PotonganPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PotonganGajiProvider>().fetchPotonganGaji();
    });
  }

  Future<void> _refreshData() async {
    await context.read<PotonganGajiProvider>().fetchPotonganGaji();
  }

  @override
  Widget build(BuildContext context) {
    final potonganProvider = context.watch<PotonganGajiProvider>();
    final displayedList = searchController.text.isEmpty
        ? potonganProvider.potonganList
        : potonganProvider.filteredPotonganGajiList;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Header(title: "Potongan"),
              SearchingBar(
                controller: searchController,
                onChanged: (value) {
                  potonganProvider.filterPotonganGaji(value);
                  print("Search Potongan: $value");
                },
                onFilter1Tap: () => print("Filter Potongan"),
              ),
              if (potonganProvider.isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: LoadingWidget()),
                )
              else if (potonganProvider.potonganList.isEmpty)
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
                          'Belum ada Potongan',
                          style: TextStyle(
                            color: AppColors.putih,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap tombol + untuk menambah Potongan Gaji baru',
                          style: TextStyle(
                            color: AppColors.putih.withOpacity(0.7),
                            fontFamily: GoogleFonts.poppins().fontFamily,
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
                PotonganTabel(
                  potonganList: displayedList,
                  onActionDone: () {
                    searchController.clear();
                  },
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PotonganForm()),
              );
            },
            backgroundColor: AppColors.secondary,
            shape: const CircleBorder(),
            child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
          ),
        ),
      ],
    );
  }
}

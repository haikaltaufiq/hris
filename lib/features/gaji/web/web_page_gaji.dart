// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/custom/sorting.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/gaji_service.dart';
import 'package:hr/features/gaji/widget/excel_export.dart';
import 'package:hr/features/gaji/gaji_provider.dart';
import 'package:hr/features/gaji/widget/gaji_card.dart';
import 'package:hr/features/gaji/widget/gaji_tabel.dart';
import 'package:provider/provider.dart';

class WebPageGaji extends StatefulWidget {
  const WebPageGaji({super.key});

  @override
  State<WebPageGaji> createState() => _WebPageGajiState();
}

class _WebPageGajiState extends State<WebPageGaji> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GajiProvider>();
      provider.loadCacheFirst();
      provider.fetchGaji();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GajiProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (context.isMobile)
              Align(
                alignment: Alignment.bottomLeft,
                child: Header(
                  title:
                      context.isIndonesian ? "Data Penggajian" : 'Payroll Data',
                ),
              ),
            SearchingBar(
              controller: searchController,
              onChanged: (val) => provider.searchGaji(val),
              onFilter1Tap: () async {
                final provider = context.read<GajiProvider>();

                final selected = await showSortDialog(
                  context: context,
                  title: 'Urutkan Gaji Berdasarkan',
                  currentValue: provider.currentSortField,
                  options: [
                    {'value': 'nama', 'label': 'Nama'},
                    {'value': 'status', 'label': 'Status'},
                  ],
                );

                if (selected != null) {
                  provider.sortGaji(selected);
                }

                if (selected != null) {
                  provider.sortGaji(selected);
                }
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                right: context.isMobile ? 0 : 16.0,
                left: context.isMobile ? 0 : 16.0,
              ),
              child: ExcelExport(),
            ),
            // 👇 ini jadi satu widget saja
            _buildContent(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GajiProvider provider) {
    if (provider.isLoading && provider.displayedList.isEmpty) {
      return _buildLoading();
    } else if (provider.error != null) {
      return _buildError(provider.error!);
    } else if (provider.displayedList.isEmpty && !provider.isLoading) {
      return _buildEmpty();
    } else {
      if (context.isMobile) {
        return Padding(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width < 600 ? 8.0 : 28.0,
            left: MediaQuery.of(context).size.width < 600 ? 8.0 : 28.0,
          ),
          child: Column(
            children: provider.displayedList
                .map((gaji) => GajiCard(
                      gaji: gaji,
                      onStatusChanged: () => provider.fetchGaji(),
                    ))
                .toList(),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: GajiTabelWeb(
            gajiList: provider.displayedList,
            onReload: (gajiId, newStatus) async {
              print('🔄 WebPageGaji onReload called');
              print('gajiId: $gajiId, newStatus: $newStatus');

              try {
                await GajiService.updateStatus(gajiId, newStatus);
                print('✅ Status updated in DB');

                // PENTING: refresh data dari server
                await provider.fetchGaji();
                print('✅ Data refreshed from server');
              } catch (e) {
                print('❌ Error: $e');
                // Tampilkan error ke user
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update status: $e')),
                  );
                }
              }
            },
          ),
        );
      }
    }
  }

  Widget _buildLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: LoadingWidget(),
        ),
      );

  Widget _buildError(String error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text("Error: $error"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<GajiProvider>().fetchGaji(),
                child: Text(context.isIndonesian ? "Coba Lagi" : 'Try Again'),
              ),
            ],
          ),
        ),
      );

  Widget _buildEmpty() => Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.money_off,
                  size: 64,
                  color: AppColors.putih.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  context.isIndonesian
                      ? 'Belum ada data gaji'
                      : "No Data available",
                  style: TextStyle(
                    color: AppColors.putih,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
}

// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/gaji/widget/excel_export.dart';
import 'package:hr/features/gaji/gaji_provider.dart';
import 'package:hr/features/gaji/widget/gaji_card.dart';
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
      provider.loadCacheFirst(); // Load cache first
      provider.fetchGaji(); // Then fetch from API
    }); // langsung fetch pas load
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
              const Align(
                alignment: Alignment.bottomLeft,
                child: Header(title: "Data Penggajian"),
              ),
            SearchingBar(
              controller: searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              onFilter1Tap: () => provider.setSorting("gaji_bersih", true),
            ),
            ExcelExport(),
            // --- Konten data gaji ---
            if (provider.isLoading && provider.displayedList.isEmpty)
              _buildLoading()
            else if (provider.error != null)
              _buildError(provider.error!)
            else if (provider.displayedList.isEmpty && !provider.isLoading)
              _buildEmpty()
            else
              Padding(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width < 600 ? 8.0 : 28.0,
                  left: MediaQuery.of(context).size.width < 600 ? 8.0 : 28.0,
                  top: MediaQuery.of(context).size.width < 600 ? 0.0 : 18.0,
                ),
                child: Column(
                  children: provider.displayedList
                      .map((gaji) => GajiCard(
                            gaji: gaji,
                            onStatusChanged: () => provider.fetchGaji(),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
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
                child: const Text("Coba Lagi"),
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
                'Belum ada data gaji',
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
      ));
}

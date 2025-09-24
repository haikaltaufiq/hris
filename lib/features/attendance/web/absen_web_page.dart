import 'package:flutter/material.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/features/gaji/widget/excel_export.dart';
import 'package:hr/features/attendance/widget/absen_web_tabel.dart';
import 'package:provider/provider.dart';

class AbsenWebPage extends StatefulWidget {
  const AbsenWebPage({super.key});

  @override
  State<AbsenWebPage> createState() => _AbsenWebPageState();
}

class _AbsenWebPageState extends State<AbsenWebPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AbsenProvider>();
      if (provider.absensi.isEmpty) {
        provider.loadCacheFirst();
        provider.fetchAbsensi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final absenProvider = context.watch<AbsenProvider>();
    final absen = searchController.text.isEmpty
        ? absenProvider.absensi
        : absenProvider.filteredAbsensi;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SearchingBar(
            controller: searchController,
            onChanged: (query) => absenProvider.searchAbsensi(query),
            onFilter1Tap: () {},
          ),
          const SizedBox(height: 5),
          if (absenProvider.isLoading && absen.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(child: LoadingWidget()),
            )
          else if (absenProvider.absensi.isEmpty && !absenProvider.isLoading)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 64,
                      color: AppColors.putih.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada Absensi',
                      style: TextStyle(
                        color: AppColors.putih,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AbsenTabelWeb(absensi: absen),
            ),
        ],
      ),
    );
  }
}

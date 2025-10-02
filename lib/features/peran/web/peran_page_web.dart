import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/peran/web/web_tabel_peran.dart';
import 'package:hr/features/peran/peran_viewmodel.dart';

class PeranPageWeb extends StatefulWidget {
  const PeranPageWeb({super.key});

  @override
  State<PeranPageWeb> createState() => _PeranPageWebState();
}

class _PeranPageWebState extends State<PeranPageWeb> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PeranViewModel>();
      if (provider.peranList.isEmpty) {
        provider.loadCacheFirst();
        provider.fetchPeran();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ChangeNotifierProvider(
        create: (_) =>
            PeranViewModel()..fetchPeran(), // bjir ini harus fetch data
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              ListView(
                children: [
                  if (context.isMobile)
                    Header(
                        title:
                            context.isIndonesian ? "Data Peran" : "Role Data"),
                  SearchingBar(controller: SearchController()),
                  WebTabelPeranWeb(), // Expanded biar tabel bisa render full height
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, AppRoutes.peranForm);
                    if (result == true) {
                      final viewModel = context.read<PeranViewModel>();
                      await viewModel.fetchPeran();
                    }
                  },
                  backgroundColor: AppColors.secondary,
                  shape: const CircleBorder(),
                  child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

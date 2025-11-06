import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/peran/web/web_tabel_peran.dart';
import 'package:hr/features/peran/peran_viewmodel.dart';

class PeranPageWeb extends StatefulWidget {
  const PeranPageWeb({super.key});

  @override
  State<PeranPageWeb> createState() => _PeranPageWebState();
}

class _PeranPageWebState extends State<PeranPageWeb> {
  late PeranViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PeranViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadCacheFirst();
      viewModel.fetchPeran();
    });
  }

  Future<void> _handleRefresh() async {
    await viewModel.fetchPeran();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView(
                  children: [
                    if (context.isMobile)
                      Header(
                        title:
                            context.isIndonesian ? "Data Peran" : "Role Data",
                      ),
                    WebTabelPeranWeb(),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, AppRoutes.peranForm);
                    if (result == true && mounted) {
                      await _handleRefresh(); // langsung refresh realtime
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/features/peran/peran_viewmodel.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';

class WebTabelPeranWeb extends StatefulWidget {
  const WebTabelPeranWeb({super.key});

  @override
  State<WebTabelPeranWeb> createState() => _WebTabelPeranWebState();
}

String formatFiturName(String value) {
  return value
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

class _WebTabelPeranWebState extends State<WebTabelPeranWeb> {
  void _handleView(PeranModel peran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.isIndonesian ? 'Detail Peran' : 'Role Detail',
          style: TextStyle(
            color: AppColors.putih,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peran.namaPeran,
                  style: TextStyle(
                    color: AppColors.putih,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                const SizedBox(height: 12),
                ...(peran.fitur.isNotEmpty
                    ? peran.fitur.map((f) => ListTile(
                          title: Text(
                            formatFiturName(f.namaFitur),
                            style: TextStyle(
                                color: AppColors.putih.withOpacity(0.8)),
                          ),
                          subtitle: Text(
                            f.deskripsiFitur,
                            style: TextStyle(
                                color: AppColors.putih.withOpacity(0.6)),
                          ),
                        ))
                    : [
                        const Text('Belum ada fitur',
                            style: TextStyle(color: Colors.white))
                      ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(
                color: AppColors.green,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEdit(PeranModel peran) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.peranForm,
      arguments: peran,
    );
    if (result == true) {
      final viewModel = context.read<PeranViewModel>();
      await viewModel.fetchPeran();
    }
  }

  Future<void> _hapusPeran(PeranModel peran) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_outline, color: AppColors.red, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Hapus Peran?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.putih),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: AppColors.putih),
                children: [
                  TextSpan(
                      text: 'Apakah Anda yakin ingin menghapus peran ',
                      style: TextStyle(color: AppColors.putih)),
                  TextSpan(
                      text: '"${peran.namaPeran}"',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: AppColors.putih)),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan',
                      style: TextStyle(color: Colors.orange, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Batal',
              style: TextStyle(color: AppColors.putih),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Hapus',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final viewModel = Provider.of<PeranViewModel>(context, listen: false);
        await viewModel.deletePeran(peran.id);
        final message = context.isIndonesian
            ? 'Peran berhasil dihapus'
            : 'Role deleted successfully';
        NotificationHelper.showTopNotification(context, message,
            isSuccess: true);
      } catch (e) {
        final message = context.isIndonesian
            ? 'Gagal menghapus: $e'
            : 'Failed to delete: $e';
        NotificationHelper.showTopNotification(context, message,
            isSuccess: false);
      }
    }
  }

  Widget _buildMobileTable(List<PeranModel> peranList) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    context.isIndonesian ? 'Nama Peran' : 'Role Name',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.bold,
                      fontSize: context.isMobile ? 15 : 13,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    context.isIndonesian ? 'Aksi' : 'Action',
                    style: TextStyle(
                      color: AppColors.putih,
                      fontWeight: FontWeight.bold,
                      fontSize: context.isMobile ? 15 : 13,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Divider(
                  color: AppColors.secondary,
                  thickness: 1,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: peranList.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.secondary, thickness: 1),
              itemBuilder: (context, index) {
                final peran = peranList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          peran.namaPeran,
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: context.isMobile ? 15 : 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => _handleView(peran),
                                child: FaIcon(
                                  FontAwesomeIcons.eye,
                                  color: AppColors.putih,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 15),
                              GestureDetector(
                                onTap: () => _handleEdit(peran),
                                child: FaIcon(
                                  FontAwesomeIcons.pen,
                                  color: AppColors.putih,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 15),
                              GestureDetector(
                                onTap: () => _hapusPeran(peran),
                                child: FaIcon(
                                  FontAwesomeIcons.trash,
                                  color: AppColors.putih,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PeranViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return const Center(child: LoadingWidget());

        final peranList = viewModel.peranList;
        if (peranList.isEmpty) {
          return Center(
            child: Text('Belum ada peran',
                style: TextStyle(color: AppColors.putih)),
          );
        }

        if (context.isMobile) {
          return _buildMobileTable(peranList);
        }

        final headers = context.isIndonesian ? ['Nama Peran'] : ["Role Name"];

        return CustomDataTableWeb(
          headers: headers,
          rows: peranList.map((p) => [p.namaPeran]).toList(),
          onView: (i) => _handleView(peranList[i]),
          onEdit: (i) => _handleEdit(peranList[i]),
          onDelete: (i) => _hapusPeran(peranList[i]),
        );
      },
    );
  }
}

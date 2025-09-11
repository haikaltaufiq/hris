import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/features/peran/peran_form/form_page.dart';
import 'package:hr/features/peran/peran_viewmodel.dart';
import 'package:provider/provider.dart';

class WebTabelPeranWeb extends StatefulWidget {
  const WebTabelPeranWeb({super.key});

  @override
  State<WebTabelPeranWeb> createState() => _WebTabelPeranWebState();
}

class _WebTabelPeranWebState extends State<WebTabelPeranWeb> {
  void _handleView(PeranModel peran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Detail Peran',
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
                // Ini nama peran paling atas
                Text(
                  peran.namaPeran,
                  style: TextStyle(
                    color: AppColors.putih,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                const SizedBox(height: 12), // spacing dikit

                // list fitur
                ...(peran.fitur.isNotEmpty
                    ? peran.fitur.map((f) => ListTile(
                          title: Text(
                            f.namaFitur,
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PeranFormPage(peran: peran)),
    );
  }

  // -------------------- HAPUS PERAN --------------------
  Future<void> _hapusPeran(PeranModel peran) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Hapus Peran?',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  const TextSpan(
                      text: 'Apakah Anda yakin ingin menghapus peran '),
                  TextSpan(
                      text: '"${peran.namaPeran}"',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final viewModel = Provider.of<PeranViewModel>(context, listen: false);
        await viewModel.deletePeran(peran.id);
        NotificationHelper.showTopNotification(
            context, 'Peran berhasil dihapus',
            isSuccess: true);
      } catch (e) {
        NotificationHelper.showTopNotification(context, 'Gagal menghapus: $e',
            isSuccess: false);
      }
    }
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

        final headers = ['Nama Peran'];
        final rows = peranList.map((p) {
          return [
            p.namaPeran,
          ];
        }).toList();

        return CustomDataTableWeb(
          headers: headers,
          rows: rows,
          columnFlexValues: const [3, 2],
          onCellTap: (rowIndex, colIndex) {
            if (colIndex == 1) _handleView(peranList[rowIndex]);
          },
          onView: (rowIndex) => _handleView(peranList[rowIndex]),
          onEdit: (rowIndex) => _handleEdit(peranList[rowIndex]),
          onDelete: (rowIndex) => _hapusPeran(peranList[rowIndex]),
        );
      },
    );
  }
}

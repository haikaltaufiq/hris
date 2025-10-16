import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/features/potongan/potongan_form/form_edit.dart';
import 'package:hr/features/potongan/view_model/potongan_gaji_provider.dart';
import 'package:provider/provider.dart';

class PotonganTabel extends StatelessWidget {
  final List<PotonganGajiModel> potonganList;
  final VoidCallback? onActionDone;

  const PotonganTabel(
      {super.key, required this.potonganList, required this.onActionDone});

  void _editPotongan(BuildContext context, PotonganGajiModel potongan) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => PotonganEdit(
          potongan: potongan,
        ),
      ),
    )
        .then((_) {
      // reload data jika diperlukan
      context.read<PotonganGajiProvider>().fetchPotonganGaji();
    });
    onActionDone?.call();
  }

  Future<void> _deletePotongan(
      BuildContext context, PotonganGajiModel potongan) async {
    // Tampilkan dialog konfirmasi dan tunggu hasil
    final confirmed = await showConfirmationDialog(
      context,
      title: "Konfirmasi Hapus",
      content: "Apakah Anda yakin ingin menghapus potongan ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      confirmColor: AppColors.red,
    );

    if (confirmed == true) {
      try {
        // Panggil provider untuk hapus potongan
        await context
            .read<PotonganGajiProvider>()
            .deletePotonganGaji(potongan.id!, "");
        // Tampilkan SnackBar sukses

        NotificationHelper.showTopNotification(
          context,
          "Potongan berhasil dihapus",
          isSuccess: true,
        );
      } catch (e) {
        // Tampilkan SnackBar gagal
        NotificationHelper.showTopNotification(
          context,
          "Gagal menghapus potongan: $e",
          isSuccess: false,
        );
      }
    }
    onActionDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> headers = context.isIndonesian
        ? [
            "Potongan",
            "Nominal",
          ]
        : [
            'Deduction',
            'Amount',
          ];

    final rows = potonganList.map((potongan) {
      return [
        potongan.namaPotongan,
        '${potongan.nominal.toStringAsFixed(1)}%',
      ];
    }).toList();

    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: const [],
      onView: (row) {
        final c = potonganList[row];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Detail Lembur',
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailItem(label: 'Nama Potongan', value: c.namaPotongan),
                DetailItem(label: 'Nominal', value: c.nominal.toString()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup',
                    style: GoogleFonts.poppins(
                      color: AppColors.putih,
                      fontSize: 16,
                    )),
              ),
            ],
          ),
        );
      },
      onEdit: (row) => _editPotongan(context, potonganList[row]),
      onDelete: (row) => _deletePotongan(context, potonganList[row]),
    );
  }
}

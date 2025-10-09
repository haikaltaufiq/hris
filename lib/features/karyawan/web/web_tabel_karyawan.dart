import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/karyawan/karyawan_form/karyawan_form_edit.dart';

import 'package:provider/provider.dart';

class KaryawanTabelWeb extends StatelessWidget {
  final List<UserModel> users;

  const KaryawanTabelWeb({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    // Headers sesuai field
    final headers = context.isIndonesian
        ? [
            "Nama",
            "Email",
            "Peran",
            "Jabatan",
            "Departemen",
            "Gaji Per Hari",
            "Jenis Kelamin",
            "Status Nikah",
            "NPWP",
            "BPJS TK",
            "BPJS KES",
          ]
        : [
            "Name",
            "Email",
            "Role",
            "Position",
            "Departemen",
            "Daily Salary",
            "Gender",
            "Marriage Status",
            "NPWP",
            "BPJS TK",
            "BPJS KES",
          ];

    // Rows diubah jadi List<List<String>> biar compatible
    final rows = users.map((user) {
      return [
        user.nama,
        user.email,
        user.peran.namaPeran,
        user.jabatan?.namaJabatan ?? '-',
        user.departemen.namaDepartemen,
        user.gajiPokok ?? '-',
        user.jenisKelamin,
        user.statusPernikahan,
        user.npwp ?? '-',
        user.bpjsKetenagakerjaan ?? '-',
        user.bpjsKesehatan ?? '-',
      ];
    }).toList();

    return CustomDataTableWeb(
      headers: headers,
      rows: rows,
      onView: (rowIndex) {
        final values = rows[rowIndex];

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.primary,
            title: Text(
              'Details',
              style: TextStyle(
                  color: AppColors.putih, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(headers.length, (index) {
                  return DetailItem(
                    label: headers[index],
                    value: values[index],
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup', style: TextStyle(color: AppColors.putih)),
              ),
            ],
          ),
        );
      },
      onEdit: (rowIndex) {
        final user = users[rowIndex];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KaryawanFormEdit(user: user),
          ),
        );
      },
      onDelete: (rowIndex) async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = users[rowIndex];
        final confirmed = await showConfirmationDialog(
          context,
          title: 'Konfirmasi',
          content: 'Yakin ingin menghapus karyawan ini?',
        );

        if (!confirmed) return;

        try {
          await userProvider.deleteUser(user.id);

          if (context.mounted) {
            NotificationHelper.showTopNotification(
              context,
              'Karyawan berhasil dihapus',
              isSuccess: true,
            );
          }
        } catch (e) {
          if (context.mounted) {
            NotificationHelper.showTopNotification(
              context,
              'Gagal menghapus karyawan: $e',
              isSuccess: false,
            );
          }
        }
      },
      onCellTap: (row, col) {
        // Bisa custom logika per cell
      },
    );
  }
}

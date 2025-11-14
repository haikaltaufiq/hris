import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/routes/app_routes.dart';

import 'package:provider/provider.dart';

class KaryawanTabelWeb extends StatelessWidget {
  final List<UserModel> users;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final VoidCallback? onActionDone;

  const KaryawanTabelWeb(
      {super.key,
      required this.users,
      required this.scaffoldMessengerKey,
      required this.onActionDone});

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
            "Department",
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
        (user.peran?.namaPeran.isNotEmpty ?? false)
            ? user.peran!.namaPeran
            : '-',
        (user.jabatan?.namaJabatan.isNotEmpty ?? false)
            ? user.jabatan!.namaJabatan
            : '-',
        (user.departemen?.namaDepartemen.isNotEmpty ?? false)
            ? user.departemen!.namaDepartemen
            : '-',
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
      onView: (actualRowIndex) {
        final values = rows[actualRowIndex];

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
      onEdit: (actualRowIndex) async {
        final user = users[actualRowIndex];
        await Navigator.pushNamed(
          context,
          AppRoutes.karyawanEditForm,
          arguments: user,
        );
      },
      onDelete: (actualRowIndex) async {
        final user = users[actualRowIndex];

        // Simpan language state sebelum dialog
        final isIndonesian = context.isIndonesian;

        final confirmed = await showConfirmationDialog(
          context,
          title: isIndonesian ? 'Konfirmasi' : 'Confirmation',
          content: isIndonesian
              ? 'Yakin ingin menghapus karyawan ini?'
              : 'Are you sure you want to delete this employee?',
        );

        if (!confirmed) return;

        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Ambil context yang stable dari ScaffoldMessenger
        final messengerContext = scaffoldMessengerKey.currentContext;

        if (messengerContext == null) {
          print('❌ ScaffoldMessenger context is null');
          return;
        }

        try {
          await userProvider.deleteUser(user.id);
          onActionDone?.call();

          final message = isIndonesian
              ? 'Karyawan berhasil dihapus'
              : 'Employee deleted successfully';

          NotificationHelper.showTopNotification(
            messengerContext, // Gunakan stable context
            message,
            isSuccess: true,
          );
        } catch (e) {
          final message = isIndonesian
              ? 'Gagal menghapus karyawan: $e'
              : 'Failed to delete employee: $e';

          NotificationHelper.showTopNotification(
            messengerContext, // Gunakan stable context
            message,
            isSuccess: false,
          );
        }
      },
      onCellTap: (paginatedRowIndex, colIndex, actualRowIndex) {
        // Bisa custom logika per cell
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/akun_service.dart';
import 'package:hr/features/buka_akun/info_danger.dart';

class BukaAkun extends StatefulWidget {
  const BukaAkun({super.key});

  @override
  State<BukaAkun> createState() => _BukaAkunState();
}

class _BukaAkunState extends State<BukaAkun> {
  List<dynamic> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await AkunService.fetchLockedUsers();
      setState(() {
        users = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      NotificationHelper.showTopNotification(context, 'Gagal ambil akun: $e',
          isSuccess: false);
    }
  }

  Future<void> _unlockUser(int userId) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: context.isIndonesian ? "Konfirmasi" : "Confirmation",
      content: context.isIndonesian
          ? "Apakah Anda yakin ingin membuka akun ini?"
          : "Are you sure you want to unlock this account?",
      confirmText: "Buka",
      cancelText: context.isIndonesian ? "Batal" : "Cancel",
      confirmColor: AppColors.red,
    );
    if (!confirmed) return;
    try {
      final success = await AkunService.unlockUser(userId);
      if (success) {
        NotificationHelper.showTopNotification(context, 'Akun berhasil dibuka',
            isSuccess: true);

        _loadUsers(); // refresh list
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Gagal buka akun: $e',
          isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile
          ? AppBar(
              title: Text(
                context.isIndonesian ? 'Buka Akun' : 'Unlock Account',
                style: TextStyle(
                    color: AppColors.putih,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily),
              ),
              backgroundColor: AppColors.bg,
              leading: IconButton(
                icon: const Icon(
                    Icons.arrow_back_ios), // atau CupertinoIcons.back
                color: AppColors.putih,
                onPressed: () => Navigator.of(context).pop(),
              ),
              iconTheme: IconThemeData(
                color: AppColors.putih, // warna ikon back
              ),
            )
          : null,
      body: loading
          ? Center(
              child: CircularProgressIndicator(
              color: AppColors.putih,
            ))
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open_rounded,
                          size: 80, color: AppColors.putih.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      Text(
                        context.isIndonesian
                            ? "Belum ada akun terkunci"
                            : "No locked accounts",
                        style: TextStyle(
                          color: AppColors.putih.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 8),
                        child: InfoBukaAkun(),
                      );
                    }
                    final user = users[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(user['nama'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.putih)),
                      subtitle: Text(
                        user['email'] ?? '',
                        style:
                            TextStyle(color: AppColors.putih.withOpacity(0.5)),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.refresh, color: AppColors.green),
                        onPressed: () => _unlockUser(user['id']),
                      ),
                      tileColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
    );
  }
}

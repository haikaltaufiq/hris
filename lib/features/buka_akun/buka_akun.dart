import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
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
    final confirmed = await _showTypeConfirmationDialog(
      context,
      title: context.isIndonesian
          ? "Konfirmasi Buka Akun"
          : "Unlock Account Confirmation",
      content: context.isIndonesian
          ? "Membuka akun akan mengizinkan pengguna untuk login kembali. Pastikan Anda yakin sebelum melanjutkan."
          : "Unlocking the account will allow the user to log in again. Make sure you are certain before proceeding.",
      confirmationText: "unlock this account",
    );

    if (!confirmed) return;

    try {
      final success = await AkunService.unlockUser(userId);
      if (success) {
        NotificationHelper.showTopNotification(context, 'Akun berhasil dibuka',
            isSuccess: true);

        _loadUsers();
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Gagal buka akun: $e',
          isSuccess: false);
    }
  }

  Future<bool> _showTypeConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmationText,
  }) async {
    final textController = TextEditingController();
    bool isMatching = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 24 : 80,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.isMobile ? double.infinity : 500,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_open_rounded,
                            color: AppColors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.putih,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.putih.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.isIndonesian
                            ? "Ketik '$confirmationText' untuk konfirmasi:"
                            : "Type '$confirmationText' to confirm:",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.putih.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: textController,
                        style: TextStyle(color: AppColors.putih),
                        decoration: InputDecoration(
                          hintText: confirmationText,
                          hintStyle: TextStyle(
                            color: AppColors.putih.withOpacity(0.4),
                          ),
                          filled: true,
                          fillColor: AppColors.bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.putih.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.putih.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.putih,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isMatching = value == confirmationText;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                side: BorderSide(
                                  color: AppColors.secondary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                textController.dispose();
                                Navigator.pop(context, false);
                              },
                              child: Text(
                                context.isIndonesian ? "Batal" : "Cancel",
                                style: TextStyle(
                                  color: AppColors.putih,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                backgroundColor: isMatching
                                    ? AppColors.green
                                    : AppColors.secondary,
                                disabledBackgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isMatching
                                  ? () {
                                      textController.dispose();
                                      Navigator.pop(context, true);
                                    }
                                  : null,
                              child: Text(
                                context.isIndonesian
                                    ? "Konfirmasi Buka"
                                    : "Confirm Unlock",
                                style: TextStyle(
                                  color: AppColors.putih,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return result ?? false;
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
                icon: const Icon(Icons.arrow_back_ios),
                color: AppColors.putih,
                onPressed: () => Navigator.of(context).pop(),
              ),
              iconTheme: IconThemeData(
                color: AppColors.putih,
              ),
            )
          : null,
      body: loading
          ? Center(child: LoadingWidget())
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
                  itemCount: users.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 8),
                        child: InfoBukaAkun(),
                      );
                    }
                    final user = users[index - 1];
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

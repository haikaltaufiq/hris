import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/akun_service.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil akun: $e')),
      );
    }
  }

  Future<void> _unlockUser(int userId) async {
    try {
      final success = await AkunService.unlockUser(userId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dibuka')),
        );
        _loadUsers(); // refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal buka akun: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: context.isMobile
          ? AppBar(
              title: Text(
                'Buka Akun',
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
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(user['nama'] ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: AppColors.putih)),
                  subtitle: Text(
                    user['email'] ?? '',
                    style: TextStyle(color: AppColors.putih.withOpacity(0.5)),
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

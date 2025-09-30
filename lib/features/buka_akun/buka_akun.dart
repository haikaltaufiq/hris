import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
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
      appBar: AppBar(title: const Text('Buka Akun Terkunci')),
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
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.green),
                    onPressed: () => _unlockUser(user['id']),
                  ),
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
    );
  }
}

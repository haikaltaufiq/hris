import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';

class BukaAkun extends StatefulWidget {
  const BukaAkun({super.key});

  @override
  State<BukaAkun> createState() => _BukaAkunState();
}

class _BukaAkunState extends State<BukaAkun> {
  final List<Map<String, String>> devices = [
    {'user': 'Haikal', 'device': 'Laptop Windows'},
    {'user': 'Rina', 'device': 'iPhone 14'},
    {'user': 'Budi', 'device': 'Android Samsung'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bg,
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: devices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(device['user'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(device['device'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: () {
                  // Hapus device dari list
                  setState(() {
                    devices.removeAt(index);
                  });
                  // Bisa juga tambahkan logika reset device di backend sini
                },
              ),
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            );
          },
        ));
  }
}

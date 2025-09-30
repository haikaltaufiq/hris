import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';

class ResetDevice extends StatefulWidget {
  const ResetDevice({super.key});

  @override
  State<ResetDevice> createState() => _ResetDeviceState();
}

class _ResetDeviceState extends State<ResetDevice> {
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
                icon: const Icon(Icons.delete, color: Colors.red),
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

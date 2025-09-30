import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/services/device_service.dart';

class ResetDevice extends StatefulWidget {
  const ResetDevice({super.key});

  @override
  State<ResetDevice> createState() => _ResetDeviceState();
}

class _ResetDeviceState extends State<ResetDevice> {
  List<dynamic> devices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final data = await DeviceService.fetchDevices();
      setState(() {
        devices = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil device: $e')),
      );
    }
  }

  Future<void> _resetDevice(int userId) async {
    try {
      final success = await DeviceService.resetDevice(userId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device berhasil direset')),
        );
        _loadDevices(); // refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal reset: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Reset Device')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    "${device['user']['nama']} (${device['device_model']})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Device ID: ${device['device_id']}"),
                      Text("Manufacturer: ${device['device_manufacturer']}"),
                      if ((device['device_version'] ?? '').isNotEmpty)
                        Text("Version: ${device['device_version']}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _resetDevice(device['user_id']),
                  ),
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }
            ),
    );
  }
}

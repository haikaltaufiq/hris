import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
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

      NotificationHelper.showTopNotification(context, 'Gagal ambil device: $e',
          isSuccess: false);
    }
  }

  Future<void> _resetDevice(int userId) async {
    try {
      final success = await DeviceService.resetDevice(userId);
      if (success) {
        NotificationHelper.showTopNotification(
            context, 'Device berhasil direset',
            isSuccess: true);

        _loadDevices(); // refresh data
      }
    } catch (e) {
      NotificationHelper.showTopNotification(context, 'Gagal reset: $e',
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
                context.isIndonesian ? 'Reset Perangkat' : 'Reset Device',
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
              itemCount: devices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    "${device['user']['nama']} (${device['device_model']})",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.putih),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Device ID:  ${device['device_id']}",
                        style:
                            TextStyle(color: AppColors.putih.withOpacity(0.5)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Manufacturer:  ${device['device_manufacturer']}",
                        style:
                            TextStyle(color: AppColors.putih.withOpacity(0.5)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if ((device['device_version'] ?? '').isNotEmpty)
                        Text(
                          "Version:  ${device['device_version']}",
                          style: TextStyle(
                              color: AppColors.putih.withOpacity(0.5)),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _resetDevice(device['user_id']),
                  ),
                  tileColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
    );
  }
}

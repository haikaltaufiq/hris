import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/tracking_service.dart';

class Locationtrackpage extends StatefulWidget {
  const Locationtrackpage({super.key});

  @override
  State<Locationtrackpage> createState() => _LocationtrackpageState();
}

class _LocationtrackpageState extends State<Locationtrackpage> {
  List<UserModel> users = [];
  Timer? _timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // 🔁 auto refresh tiap 1 menit
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _loadData(),
    );
  }

  Future<void> _loadData() async {
    try {
      final result = await TrackingService.getTrackingUsers();
      setState(() {
        users = result;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = users.isNotEmpty
        ? LatLng(users.first.latitude!, users.first.longitude!)
        : const LatLng(-6.200000, 106.816666);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.hr',
                ),

                MarkerLayer(
                  markers: users
                      .where((u) => u.latitude != null && u.longitude != null)
                      .map(
                        (user) => Marker(
                          width: 50,
                          height: 50,
                          point: LatLng(user.latitude!, user.longitude!),
                          child: GestureDetector(
                            onTap: () => _showInfo(user),
                            child: Icon(
                              Icons.location_pin,
                              size: 45,
                              color: user.isGpsActive
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }

  void _showInfo(UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.nama,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              user.isGpsActive ? 'GPS Aktif' : 'GPS Tidak Aktif',
              style: TextStyle(
                color: user.isGpsActive ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Update: ${user.lastUpdate}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

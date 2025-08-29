import 'package:flutter/material.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:hr/data/services/absen_service.dart';
import 'package:hr/routes/app_routes.dart';

import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';

class AbsenTabelWeb extends StatefulWidget {
  @override
  State<AbsenTabelWeb> createState() => _AbsenTabelWebState();
}

class _AbsenTabelWebState extends State<AbsenTabelWeb> {
  final List<String> headers = const [
    "Nama",
    "Tanggal Masuk",
    "Tanggal Keluar",
    "Absen Masuk",
    "Absen Keluar",
    "Lokasi Masuk",
    "Lokasi Keluar",
    "Video",
    "Tipe",
  ];

  List<AbsenModel> absensi = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAbsensi();
  }

  Future<void> loadAbsensi() async {
    try {
      final data = await AbsenService.fetchAbsensi();
      setState(() {
        absensi = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat absensi: $e")),
      );
    }
  }

  List<List<String>> get rows {
    return absensi.map((item) {
      return [
        item.user?.nama ?? "-",
        item.checkinDate ?? "-",
        item.checkoutDate ?? "-",
        item.checkinTime ?? "-",
        item.checkoutTime ?? "-",
        (item.checkinLat != null && item.checkinLng != null)
            ? "See Location"
            : "-",
        (item.checkoutLat != null && item.checkoutLng != null)
            ? "See Location"
            : "-",
        (item.videoUser != null && item.videoUser!.isNotEmpty)
            ? "See Video"
            : "-",
        item.status ?? "-",
      ];
    }).toList();
  }

  /// --- Lokasi tampil di BottomSheet dengan mini Map
  void _openMap(String latlongStr) {
    try {
      final parts = latlongStr.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      Navigator.pushNamed(context, AppRoutes.mapPage,
          arguments: LatLng(lat, lng));
    } catch (_) {
      debugPrint("Format latlong salah: $latlongStr");
    }
  }

  /// --- Video tampil di Fullscreen Dialog Stylish
  void _openVideo(String? videoPath) {
    if (videoPath == null || videoPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada video")),
      );
      return;
    }

    final controller = VideoPlayerController.network(
      "${ApiConfig.baseUrl}/storage/$videoPath",
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (_, __, ___) {
        return FutureBuilder(
          future: controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              controller.play();
              return Scaffold(
                backgroundColor: Colors.black.withOpacity(0.9),
                body: Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 32),
                        onPressed: () {
                          controller.dispose();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              controller.value.isPlaying
                                  ? controller.pause()
                                  : controller.play();
                            });
                          },
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: LoadingWidget());
          },
        );
      },
    );
  }

  void _showDetail(AbsenModel absen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Detail Absen',
          style: TextStyle(color: AppColors.putih),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailItem(label: "Nama", value: absen.user?.nama ?? "-"),
            DetailItem(label: "Tanggal Masuk", value: absen.checkinDate ?? "-"),
            DetailItem(
                label: "Tanggal Keluar", value: absen.checkoutDate ?? "-"),
            DetailItem(label: "Absen Masuk", value: absen.checkinTime ?? "-"),
            DetailItem(label: "Absen Keluar", value: absen.checkoutTime ?? "-"),
            DetailItem(
              label: "Lokasi Masuk",
              value: "${absen.checkinLat}, ${absen.checkinLng}",
            ),
            DetailItem(
              label: "Lokasi Keluar",
              value: "${absen.checkoutLat}, ${absen.checkoutLng}",
            ),
            DetailItem(label: "Video", value: absen.videoUser ?? "-"),
            DetailItem(label: "Tipe", value: absen.status ?? "-"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(color: AppColors.putih),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: LoadingWidget());
    }

    return CustomDataTableWeb(
      headers: headers,
      rows: rows,
      statusColumnIndexes: null,
      onCellTap: (rowIndex, colIndex) {
        final absen = absensi[rowIndex];

        if (colIndex == 5 &&
            absen.checkinLat != null &&
            absen.checkinLng != null) {
          _openMap("${absen.checkinLat}, ${absen.checkinLng}");
        } else if (colIndex == 6 &&
            absen.checkoutLat != null &&
            absen.checkoutLng != null) {
          _openMap("${absen.checkoutLat}, ${absen.checkoutLng}");
        } else if (colIndex == 7 &&
            absen.videoUser != null &&
            absen.videoUser!.isNotEmpty) {
          _openVideo(absen.videoUser);
        }
      },
      onView: (rowIndex) => _showDetail(absensi[rowIndex]),
    );
  }
}

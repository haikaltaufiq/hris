import 'package:flutter/material.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:hr/routes/app_routes.dart';

import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';

class AbsenTabelWeb extends StatefulWidget {
  final List<AbsenModel> absensi;
  const AbsenTabelWeb({
    super.key,
    required this.absensi,
  });

  @override
  State<AbsenTabelWeb> createState() => _AbsenTabelWebState();
}

class _AbsenTabelWebState extends State<AbsenTabelWeb> {
  final List<String> headers = const [
    "Nama",
    "Tanggal",
    "Absen Masuk",
    "Absen Keluar",
    "Lokasi Masuk",
    "Lokasi Keluar",
    "Video",
    "Status",
  ];

  bool loading = true;

  List<List<String>> get rows {
    return widget.absensi.map((item) {
      return [
        item.user?.nama ?? "-",
        item.checkinDate ?? "-",
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
      // debugPrint("Format latlong salah: $latlongStr");
    }
  }

  /// --- Video tampil di Fullscreen Dialog
  void _openVideo(String? videoPath) {
    if (videoPath == null || videoPath.isEmpty) {
      final message =
          context.isIndonesian ? "Tidak ada video" : "No video available";
      NotificationHelper.showTopNotification(context, message,
          isSuccess: false);
      return;
    }

    final fullUrl = videoPath.startsWith('http')
        ? videoPath
        : "${ApiConfig.baseUrl}$videoPath";

    final controller = VideoPlayerController.network(fullUrl);

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
              return StatefulBuilder(
                builder: (context, setStateDialog) {
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
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32,
                            ),
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
                                if (controller.value.isPlaying) {
                                  controller.pause();
                                } else {
                                  controller.play();
                                }
                                setStateDialog(() {}); // refresh icon
                              },
                              child: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.black,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
            DetailItem(
                label: context.isIndonesian ? "Nama" : "Name",
                value: absen.user?.nama ?? "-"),
            DetailItem(
                label: context.isIndonesian ? "Tanggal Masuk" : "Check-in Date",
                value: absen.checkinDate ?? "-"),
            DetailItem(
                label:
                    context.isIndonesian ? "Tanggal Keluar" : "Check-out Date",
                value: absen.checkoutDate ?? "-"),
            DetailItem(
                label: context.isIndonesian ? "Absen Masuk" : "Check-in Time",
                value: absen.checkinTime ?? "-"),
            DetailItem(
                label: context.isIndonesian ? "Absen Keluar" : "Check-out Time",
                value: absen.checkoutTime ?? "-"),
            DetailItem(label: "Status", value: absen.status ?? "-"),
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
    return CustomDataTableWeb(
      headers: headers,
      rows: rows,
      statusColumnIndexes: null,
      onCellTap: (paginatedRowIndex, colIndex, actualRowIndex) {
        final absen = widget.absensi[actualRowIndex];

        if (colIndex == 4 &&
            absen.checkinLat != null &&
            absen.checkinLng != null) {
          _openMap("${absen.checkinLat}, ${absen.checkinLng}");
        } else if (colIndex == 5 &&
            absen.checkoutLat != null &&
            absen.checkoutLng != null) {
          _openMap("${absen.checkoutLat}, ${absen.checkoutLng}");
        } else if (colIndex == 6 &&
            absen.videoUser != null &&
            absen.videoUser!.isNotEmpty) {
          _openVideo(absen.videoUser);
        }
      },
      onView: (actualRowIndex) => _showDetail(widget.absensi[actualRowIndex]),
    );
  }
}

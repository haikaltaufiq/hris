import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/data/models/absen_model.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/attendance/mobile/components/map.dart';
import 'package:video_player/video_player.dart';

class DetailAbsen extends StatefulWidget {
  final AbsenModel selectedAbsen;
  const DetailAbsen({super.key, required this.selectedAbsen});

  @override
  State<DetailAbsen> createState() => _DetailAbsenState();
}

class _DetailAbsenState extends State<DetailAbsen> {
  late final List<Marker> _markers;

  @override
  void initState() {
    super.initState();
    // marker final cuma sekali
    _markers = (widget.selectedAbsen.checkinLat != null &&
            widget.selectedAbsen.checkinLng != null)
        ? [
            Marker(
              width: 40,
              height: 40,
              point: LatLng(widget.selectedAbsen.checkinLat!,
                  widget.selectedAbsen.checkinLng!),
              child: const Icon(
                Icons.location_pin,
                size: 40,
                color: Colors.red,
              ),
            ),
          ]
        : [];
  }

  // ================= VIDEO =================
  void _openVideo(String? videoPath) {
    if (videoPath == null || videoPath.isEmpty) {
      final message =
          context.isIndonesian ? "Tidak ada video" : "No video available";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
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
                                setStateDialog(() {});
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final center = _markers.isNotEmpty
        ? _markers.first.point
        : const LatLng(-6.200000, 106.816666);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // ================= MAP =================
          SizedBox(
            height: 320,
            child: MapPersonal(
              markers: _markers,
              center: center,
            ),
          ),

          // ================= DETAIL =================
          Expanded(
            child: Consumer<AbsenProvider>(
              builder: (context, absen, _) {
                if (absen.isLoading) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: AppColors.putih,
                  ));
                }

                if (absen.errorMessage != null) {
                  return Center(
                    child: Text(
                      absen.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final today = absen.todayAbsensi;
                if (today.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada absensi hari ini",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final data = widget.selectedAbsen;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _infoTileText(context.isIndonesian ? "Nama" : "Name",
                        data.user?.nama ?? "-"),
                    _infoTileText(context.isIndonesian ? "Tanggal" : "Date",
                        data.checkinDate ?? "-"),
                    _infoTileText("Status", data.status ?? "-"),
                    _infoTileText(
                        context.isIndonesian ? "Jam Masuk" : "Check-in",
                        data.checkinTime ?? "-"),
                    _infoTileText(
                        context.isIndonesian ? "Jam Keluar" : "Check-out",
                        data.checkoutTime ?? "-"),
                    _infoTileText(
                      context.isIndonesian ? "Lokasi" : "Location",
                      "${data.checkinLat}, ${data.checkinLng}",
                    ),
                    _infoTileWidget(
                      "Video",
                      InkWell(
                        onTap: data.videoUser == null || data.videoUser!.isEmpty
                            ? null
                            : () => _openVideo(data.videoUser),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 6),
                            Text(
                              data.videoUser == null
                                  ? context.isIndonesian
                                      ? "Tidak ada video"
                                      : "No video"
                                  : context.isIndonesian
                                      ? "Putar video"
                                      : "See video",
                              style: TextStyle(
                                color: data.videoUser == null
                                    ? Colors.grey
                                    : Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= TILE =================
  Widget _infoTileText(String label, String value) {
    return _baseTile(
      label,
      Text(
        value,
        style: TextStyle(
          color: AppColors.putih,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoTileWidget(String label, Widget child) {
    return _baseTile(label, child);
  }

  Widget _baseTile(String label, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label : ",
              style: TextStyle(
                color: AppColors.putih,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: content,
          ),
        ],
      ),
    );
  }
}

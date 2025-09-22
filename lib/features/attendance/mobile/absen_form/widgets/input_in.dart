// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_final_fields, avoid_print

import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/camera/camera.dart';
import 'package:hr/components/camera/video_priview.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/helpers/video_file_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/services/location_service.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class InputIn extends StatefulWidget {
  const InputIn({super.key});

  @override
  State<InputIn> createState() => _InputInState();
}

class _InputInState extends State<InputIn> with SingleTickerProviderStateMixin {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _jamMulaiController = TextEditingController();

  //----------- Camera ------------//
  final CameraManager cameraManager = CameraManager();
  XFile? _lastVideo;
  VideoPlayerController? _inlinePlayer;
  final cameraController = CameraFieldController();
  late AnimationController _progressCtrl;
  static const int maxSeconds = 15;
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: maxSeconds),
    );

    // Auto set tanggal & jam dari device
    final now = DateTime.now();
    _tanggalController.text =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _jamMulaiController.text =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _initCamera() async {
    await cameraManager.initFrontCamera();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _jamMulaiController.dispose();
    _timer?.cancel();
    _progressCtrl.dispose();
    cameraManager.dispose();
    _inlinePlayer?.dispose();
    super.dispose();
  }

  String _formatMMSS(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    return "${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}";
  }

  Future<void> _onStartHold() async {
    if (!cameraManager.isInitialized) return;
    HapticFeedback.mediumImpact();
    _elapsed = 0;
    _progressCtrl.forward(from: 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _elapsed++);
      if (_elapsed >= maxSeconds) _onEndHold();
    });

    await cameraManager.startRecording();
    if (!mounted) return;
    setState(() {}); // show overlay
  }

  Future<void> _onEndHold() async {
    _timer?.cancel();
    _progressCtrl.stop();
    final file = await cameraManager.stopRecording();
    if (!mounted) return;
    setState(() {});

    if (file != null) {
      _lastVideo = file;

      _inlinePlayer?.dispose();
      _inlinePlayer = await VideoFileHelper.getController(file);
      await _inlinePlayer!.initialize();
      _inlinePlayer!.play();
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = InputDecoration(
      hintStyle: TextStyle(color: AppColors.putih),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.putih),
      ),
    );

    final labelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      color: AppColors.putih,
      fontSize: 16,
    );

    final textStyle = GoogleFonts.poppins(
      color: AppColors.putih,
      fontSize: 14,
    );

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: "Tanggal",
                hint: "dd / mm / yyyy",
                readOnly: true,
                controller: _tanggalController,
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              CustomInputField(
                label: "Jam Masuk",
                hint: "--:--",
                readOnly: true,
                controller: _jamMulaiController,
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              // Lokasi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Lokasi",
                      style: labelStyle,
                    ),
                  ),
                  TextFormField(
                    controller: _lokasiController,
                    style: textStyle,
                    decoration: inputStyle.copyWith(
                      hintText: "Koordinat lokasi Anda",
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.secondary.withOpacity(0.8),
                                AppColors.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                );

                                final position =
                                    await LocationService.getCurrentPosition();
                                Navigator.pop(context);

                                if (!mounted) return;

                                if (position == null) {
                                  NotificationHelper.showTopNotification(
                                    context,
                                    "GPS mati atau izin ditolak",
                                    isSuccess: false,
                                  );
                                  return;
                                }

                                setState(() {
                                  _lokasiController.text =
                                      "${position.latitude}, ${position.longitude}";
                                });

                                HapticFeedback.lightImpact();

                                NotificationHelper.showTopNotification(
                                  context,
                                  "Lokasi berhasil didapatkan",
                                  isSuccess: true,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.my_location,
                                      color: AppColors.putih, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Ambil Lokasi",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.putih,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.putih.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_lokasiController.text.isEmpty) {
                                  NotificationHelper.showTopNotification(
                                    context,
                                    "Ambil lokasi terlebih dahulu",
                                    isSuccess: false,
                                  );
                                  return;
                                }
                                try {
                                  final parts =
                                      _lokasiController.text.split(',');
                                  final lat = double.parse(parts[0].trim());
                                  final lng = double.parse(parts[1].trim());
                                  HapticFeedback.selectionClick();
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: AppColors.bg,
                                    isScrollControlled: true,
                                    builder: (_) => DraggableScrollableSheet(
                                      initialChildSize: 0.9,
                                      minChildSize: 0.5,
                                      maxChildSize: 1.0,
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(20)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10,
                                                offset: const Offset(0, -3),
                                              )
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              // Konten bisa discroll
                                              Column(
                                                children: [
                                                  // Handle bar
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    height: 5,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[400],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Lokasi Absen",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: AppColors.putih,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // Map full tinggi fix
                                                  Expanded(
                                                    child: MapPageModal(
                                                        target:
                                                            LatLng(lat, lng)),
                                                  ),

                                                  const SizedBox(
                                                      height:
                                                          200), // dummy biar bisa full drag
                                                ],
                                              ),

                                              // Card info nempel di bawah
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                bottom: 0,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: LocationInfoCard(
                                                    target: LatLng(lat, lng),
                                                    mapController:
                                                        MapController(),
                                                    onConfirm: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } catch (e) {
                                  NotificationHelper.showTopNotification(
                                    context,
                                    "Format lokasi tidak valid",
                                    isSuccess: false,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map_outlined,
                                      color: AppColors.putih.withOpacity(0.9),
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Lihat Peta",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.putih.withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              // Kamera & Video
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Video", style: labelStyle),
                  ),
                  if (_lastVideo == null) ...[
                    _buildBeforeRecordUI(),
                  ] else ...[
                    _buildAfterRecordUI(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1F1F),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (cameraManager.isRecording && cameraManager.controller != null)
          Center(
            child: AnimatedBuilder(
              animation: _progressCtrl,
              builder: (_, __) => RecorderOverlay(
                controller: cameraManager.controller!,
                progress: _progressCtrl.value,
                timerText: _formatMMSS(_elapsed),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBeforeRecordUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFBFBFBF).withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFBFBFBF).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFBFBFBF), width: 2),
            ),
            child: Icon(Icons.videocam, size: 40, color: Color(0xFFBFBFBF)),
          ),
          const SizedBox(height: 16),
          Text("Belum Ada Video",
              style: GoogleFonts.poppins(
                  color: AppColors.putih,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Tekan dan tahan tombol di bawah untuk merekam",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 20),
          GestureDetector(
            onLongPressStart: (_) => _onStartHold(),
            onLongPressEnd: (_) => _onEndHold(),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.red.withOpacity(0.8), Colors.red]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fiber_manual_record,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                      cameraManager.isRecording
                          ? "Merekam..."
                          : "Tahan untuk Rekam",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          if (cameraManager.isRecording) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2)),
              child: AnimatedBuilder(
                animation: _progressCtrl,
                builder: (context, child) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressCtrl.value,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(2))),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _progressCtrl,
              builder: (context, child) => Text(
                  "${_formatMMSS(_elapsed)} / ${_formatMMSS(maxSeconds)}",
                  style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAfterRecordUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Icon(Icons.check_circle, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Text("Video Berhasil Direkam",
              style: GoogleFonts.poppins(
                  color: AppColors.putih,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Video siap untuk di-submit atau Anda bisa melihat hasilnya",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildButton("Lihat Hasil", AppColors.secondary,
                    Icons.play_circle_outline, () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              VideoPreviewScreen(videoFile: _lastVideo!)));
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                    "Rekam Ulang", Colors.red.withOpacity(0.2), Icons.refresh,
                    () {
                  HapticFeedback.selectionClick();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.primary,
                      title: Text("Rekam Ulang?",
                          style: GoogleFonts.poppins(
                              color: AppColors.putih,
                              fontWeight: FontWeight.bold)),
                      content: Text(
                          "Video yang sudah direkam akan dihapus. Lanjutkan?",
                          style: GoogleFonts.poppins(
                              color: AppColors.putih.withOpacity(0.8))),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Batal",
                                style: GoogleFonts.poppins(
                                    color: AppColors.putih.withOpacity(0.7)))),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _lastVideo = null);
                            _inlinePlayer?.dispose();
                            _inlinePlayer = null;
                            NotificationHelper.showTopNotification(
                                context, "Video dihapus, siap merekam ulang",
                                isSuccess: true);
                          },
                          child: Text("Ya, Rekam Ulang",
                              style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String text, Color color, IconData icon, VoidCallback onTap) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: color,
        gradient: text == "Lihat Hasil"
            ? LinearGradient(colors: [color.withOpacity(0.8), color])
            : null,
        borderRadius: BorderRadius.circular(12),
        border: text == "Rekam Ulang"
            ? Border.all(color: Colors.red.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: text == "Lihat Hasil"
            ? [
                BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: text == "Rekam Ulang"
                      ? Colors.red.withOpacity(0.8)
                      : AppColors.putih,
                  size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.poppins(
                  color: text == "Rekam Ulang"
                      ? Colors.red.withOpacity(0.8)
                      : AppColors.putih,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCheckIn() async {
    if (_lastVideo == null) {
      if (!mounted) return;
      NotificationHelper.showTopNotification(
          context, "Rekam video dulu sebelum submit",
          isSuccess: false);
      return;
    }
    if (_lokasiController.text.isEmpty) {
      if (!mounted) return;
      NotificationHelper.showTopNotification(
          context, "Ambil lokasi dulu sebelum submit",
          isSuccess: false);
      return;
    }
    final absenProvider = context.read<AbsenProvider>();
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final parts = _lokasiController.text.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      if (kIsWeb) {
        if (!await VideoFileHelper.isVideoSizeValid(_lastVideo!,
            maxSizeInMB: 50)) {
          Navigator.pop(context);
          NotificationHelper.showTopNotification(
              context, "Ukuran video terlalu besar (max 50MB)",
              isSuccess: false);
          return;
        }
        final videoBytes = await VideoFileHelper.getVideoBytes(_lastVideo!);
        await absenProvider.checkin(
          lat: lat,
          lng: lng,
          checkinDate: _tanggalController.text,
          checkinTime: _jamMulaiController.text,
          videoPath: _lastVideo!.path,
          videoBytes: videoBytes,
        );
      } else {
        await absenProvider.checkin(
          lat: lat,
          lng: lng,
          checkinDate: _tanggalController.text,
          checkinTime: _jamMulaiController.text,
          videoPath: _lastVideo!.path,
        );
      }

      Navigator.pop(context); // tutup loading

      if (absenProvider.lastCheckinResult?['success'] == true) {
        NotificationHelper.showTopNotification(
          context,
          absenProvider.lastCheckinResult?['message'] ?? "Check-in berhasil",
          isSuccess: true,
        );
        Navigator.of(context).pop(true);
        setState(() {
          _lastVideo = null;
          _lokasiController.clear();
        });

        _inlinePlayer?.dispose();
        _inlinePlayer = null;
      } else {
        NotificationHelper.showTopNotification(
          context,
          absenProvider.lastCheckinResult?['message'] ?? "Check-in gagal",
          isSuccess: false,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error during checkin: $e');
      NotificationHelper.showTopNotification(
        context,
        "Error: ${e.toString().replaceAll('Exception: ', '')}",
        isSuccess: false,
      );
    }
  }
}

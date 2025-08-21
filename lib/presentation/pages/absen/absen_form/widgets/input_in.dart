import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/camera/camera.dart';
import 'package:hr/components/camera/video_priview.dart';
import 'package:hr/components/custom/custom_camera_input.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/timepicker/time_picker.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/data/services/location_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';

class InputIn extends StatefulWidget {
  const InputIn({super.key});

  @override
  State<InputIn> createState() => _InputInState();
}

class _InputInState extends State<InputIn> with SingleTickerProviderStateMixin {
  final LatLng kantor = LatLng(1.1249392078070048, 104.02907149120136);
  final double maxDistance = 100; // meter
  List<Map<String, dynamic>> _riwayatAbsen = [];
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _jamMulaiController = TextEditingController();
  int _selectedMinute = 0;
  int _selectedHour = 0;

//----------- Camera ------------//
  final CameraManager cameraManager = CameraManager();
  XFile? _lastVideo;
  VideoPlayerController? _inlinePlayer;
  final cameraController = CameraFieldController();
  late AnimationController _progressCtrl;
  static const int maxSeconds = 15;
  Timer? _timer;
  int _elapsed = 0;

  void _onTapIcon(TextEditingController controller) async {
    showModalBottomSheet(
      backgroundColor: AppColors.primary,
      useRootNavigator: true,
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ListTile(
                    title: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Pilih Waktu',
                            style: TextStyle(
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Jam',
                            style: TextStyle(
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  NumberPickerWidget(
                    hour: _selectedHour,
                    minute: _selectedMinute,
                    onHourChanged: (value) {
                      setModalState(() {
                        _selectedHour = value;
                      });
                    },
                    onMinuteChanged: (value) {
                      setModalState(() {
                        _selectedMinute = value;
                      });
                    },
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: AppColors.secondary,
                    onPressed: () {
                      // Format waktu menjadi HH:mm
                      final formattedHour =
                          _selectedHour.toString().padLeft(2, '0');
                      final formattedMinute =
                          _selectedMinute.toString().padLeft(2, '0');
                      final formattedTime = "$formattedHour:$formattedMinute";

                      // Simpan ke text field controller
                      controller.text = formattedTime;

                      Navigator.pop(context);
                    },
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          color: AppColors.putih,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: maxSeconds),
    );
  }

  Future<void> _initCamera() async {
    await cameraManager.initFrontCamera(); // auto kamera depan
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
      setState(() => _elapsed++);
      if (_elapsed >= maxSeconds) _onEndHold();
    });
    await cameraManager.startRecording();
    setState(() {}); // show overlay
  }

  Future<void> _onEndHold() async {
    _timer?.cancel();
    _progressCtrl.stop();
    final file = await cameraManager.stopRecording();
    setState(() {}); // hide overlay
    if (file != null) {
      _lastVideo = file;
      _inlinePlayer?.dispose();
      _inlinePlayer = VideoPlayerController.file(File(file.path))
        ..initialize().then((_) {
          _inlinePlayer!.play();
          setState(() {});
        });
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
                label: "Nama",
                hint: "",
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              CustomInputField(
                label: "Tanggal",
                hint: "dd / mm / yyyy",
                controller: _tanggalController,
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
                onTapIcon: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary:
                                Color(0xFF1F1F1F), // Header & selected date
                            onPrimary: Colors.white, // Teks tanggal terpilih
                            onSurface: AppColors.hitam, // Teks hari/bulan
                            secondary: AppColors
                                .yellow, // Hari yang di-hover / highlight
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  AppColors.hitam, // Tombol CANCEL/OK
                            ),
                          ),
                          textTheme: GoogleFonts.poppinsTextTheme(
                            Theme.of(context).textTheme.apply(
                                  bodyColor: AppColors.hitam,
                                  displayColor: AppColors.hitam,
                                ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null && mounted) {
                    _tanggalController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')} / ${pickedDate.month.toString().padLeft(2, '0')} / ${pickedDate.year}";
                  }
                },
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              CustomDropDownField(
                label: 'Tipe Absen',
                hint: '',
                items: ['Hadir', 'Telat', 'Izin'],
                labelStyle: labelStyle,
                textStyle: textStyle,
                dropdownColor: AppColors.secondary,
                dropdownTextColor: AppColors.putih,
                dropdownIconColor: AppColors.putih,
                inputStyle: inputStyle,
              ),
              CustomInputField(
                label: "Jam Masuk",
                hint: "--:--",
                controller: _jamMulaiController,
                suffixIcon: Icon(Icons.access_time, color: AppColors.putih),
                onTapIcon: () => _onTapIcon(_jamMulaiController),
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              CustomInputField(
                label: "Lokasi",
                hint: "",
                controller: _lokasiController,
                suffixIcon:
                    Icon(Icons.location_history, color: AppColors.putih),
                onTapIcon: () async {
                  final position = await LocationService.getCurrentPosition();
                  if (position == null) {
                    NotificationHelper.showTopNotification(
                      context,
                      "GPS mati atau izin ditolak",
                      isSuccess: false,
                    );
                    return;
                  }

                  // Update controller langsung dengan lat,long
                  _lokasiController.text =
                      "${position.latitude}, ${position.longitude}";

                  final distance = LocationService.distance(
                    LatLng(position.latitude, position.longitude),
                    kantor,
                  );

                  String status =
                      distance <= maxDistance ? "Sukses ✅" : "Gagal ❌";
                  bool isSuccess = distance <= maxDistance;

                  setState(() {
                    _riwayatAbsen.add({
                      "lat": position.latitude,
                      "lng": position.longitude,
                      "time": DateTime.now().toString(),
                      "status": status,
                    });
                  });
                  NotificationHelper.showTopNotification(
                    context,
                    "$status (${distance.toStringAsFixed(2)} m dari kantor)",
                    isSuccess: isSuccess,
                  );
                },
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
              ),
              CustomCameraField(
                label: "Video",
                hint: "Hold to record ",
                labelStyle: labelStyle,
                textStyle: textStyle,
                inputStyle: inputStyle,
                controller: null,
                suffixIcon: Icon(Icons.camera_alt, color: AppColors.putih),
                onLongPressStart: _onStartHold,
                onLongPressEnd: _onEndHold,
                onTap: () {
                  if (_lastVideo != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VideoPreviewScreen(videoFile: _lastVideo!),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: handle submit
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1F1F1F),
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
        // Overlay lingkaran WA-style saat RECORDING
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
        // // Video preview inline
        // if (_inlinePlayer != null && _inlinePlayer!.value.isInitialized)
        //   AspectRatio(
        //     aspectRatio: _inlinePlayer!.value.aspectRatio,
        //     child: VideoPlayer(_inlinePlayer!),
        //   ),
      ],
    );
  }
}

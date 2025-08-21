import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CameraFieldController {
  XFile? videoFile;

  void setVideo(XFile file) {
    videoFile = file;
  }

  void clear() {
    videoFile = null;
  }
}

/// ------------------------------
/// 1) CameraManager
/// ------------------------------
class CameraManager {
  CameraController? controller;
  bool isInitialized = false;
  bool isRecording = false;
  final List<XFile> recordedVideos = [];

  Future<void> initFrontCamera() async {
    final cams = await availableCameras();
    final front = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );
    controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: true,
    );
    await controller!.initialize();
    isInitialized = true;
  }

  Future<void> startRecording() async {
    if (!isInitialized || controller == null || isRecording) return;
    isRecording = true;
    await controller!.startVideoRecording();
  }

  Future<XFile?> stopRecording() async {
    if (!isInitialized || controller == null || !isRecording) return null;
    isRecording = false;
    final file = await controller!.stopVideoRecording();
    recordedVideos.add(file);
    return file;
  }

  void dispose() {
    controller?.dispose();
  }
}

/// ------------------------------
/// 2) RecorderOverlay (circle preview + progress)
/// ------------------------------
class RecorderOverlay extends StatelessWidget {
  final CameraController controller;
  final double progress; // 0..1
  final String timerText; // e.g. 00:12
  final double size;
  final double strokeWidth;

  const RecorderOverlay({
    super.key,
    required this.controller,
    required this.progress,
    required this.timerText,
    this.size = 320,
    this.strokeWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Progress border
            CustomPaint(
              size: Size(size, size),
              painter: _CircularProgressPainter(
                progress: progress,
                strokeWidth: strokeWidth,
              ),
            ),
            // Camera preview clipped to circle
            Positioned.fill(
              child: ClipOval(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.previewSize?.height ?? size,
                    height: controller.value.previewSize?.width ?? size,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ),
            // Timer badge
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timerText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  _CircularProgressPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - strokeWidth) / 2;

    final bg = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(c, r, bg);

    final fg = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0, 1);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}

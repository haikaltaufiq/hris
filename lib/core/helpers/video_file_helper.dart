import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'dart:io' as io;

class VideoFileHelper {
  // Method yang sudah ada - untuk video player controller
  static Future<VideoPlayerController> getController(XFile videoFile) async {
    if (kIsWeb) {
      return VideoPlayerController.network(videoFile.path);
    } else {
      return VideoPlayerController.file(io.File(videoFile.path));
    }
  }

  // Method baru untuk mendapatkan bytes dari video file
  static Future<Uint8List> getVideoBytes(XFile videoFile) async {
    try {
      // Ini bekerja untuk web dan mobile
      return await videoFile.readAsBytes();
    } catch (e) {
      throw Exception('Error reading video file: $e');
    }
  }

  // Method untuk validasi ukuran file (opsional)
  static Future<bool> isVideoSizeValid(XFile videoFile, {int maxSizeInMB = 50}) async {
    try {
      final bytes = await getVideoBytes(videoFile);
      final sizeInMB = bytes.length / (1024 * 1024);
      print('Video size: ${sizeInMB.toStringAsFixed(2)} MB');
      return sizeInMB <= maxSizeInMB;
    } catch (e) {
      print('Error checking video size: $e');
      return false;
    }
  }

  // Method untuk convert video ke base64 (fallback)
  static Future<String> videoToBase64(XFile videoFile) async {
    final bytes = await getVideoBytes(videoFile);
    return base64Encode(bytes);
  }
}
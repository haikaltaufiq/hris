// ---------- Video Preview Screen ----------
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// ------------------------------
/// Video Preview (opsional)
/// ------------------------------
class VideoPreviewScreen extends StatefulWidget {
  final XFile videoFile;
  const VideoPreviewScreen({super.key, required this.videoFile});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(File(widget.videoFile.path))
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Video Preview")),
      body: Center(
        child: _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

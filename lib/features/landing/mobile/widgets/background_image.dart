import 'dart:math' as math;
import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 2.2,
      child: Transform.scale(
        scale: 2.35,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/dahua.jpg'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePreloader {
  static Future<void> preloadImages(BuildContext context) async {
    await precacheImage(const AssetImage('assets/images/dahua.jpg'), context);
    // You can add more images here:
    // await precacheImage(const AssetImage('assets/images/other_image.jpg'), context);
  }
}

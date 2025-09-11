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
        child: SizedBox.expand(
          // ganti Container kosong jadi ini
          child: Image.asset(
            'assets/images/dahua.webp',
            fit: BoxFit.contain, // sama kayak DecorationImage lo
          ),
        ),
      ),
    );
  }
}

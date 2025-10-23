import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:hr/core/theme/app_colors.dart';

// =======================================================================
// ANIMATED PAINTERS FOR BLOBS
// =======================================================================

/// Animated top-left main blob with pulsing effect
// ignore: unused_element
class _TopLeftBlobPainter extends CustomPainter {
  final Animation<double> animation;

  _TopLeftBlobPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = 1.0 + (math.sin(animation.value * 2 * math.pi) * 0.1);
    final opacity = 0.7 + (math.sin(animation.value * 2 * math.pi) * 0.2);

    final paint = Paint()..style = PaintingStyle.fill;
    final color1 = AppColors.blue.withOpacity(0.3);
    final color2 = AppColors.blue.withOpacity(0.5);

    paint.shader = LinearGradient(
      colors: [color1.withOpacity(opacity), color2.withOpacity(opacity * 0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.scale(scale, scale);

    final path = Path();
    path.moveTo(size.width * 0.4, 0);
    path.cubicTo(
      size.width * 0.7,
      0,
      size.width * 0.95,
      size.height * 0.1,
      size.width * 1.0,
      size.height * 0.3,
    );
    path.cubicTo(
      size.width * 1.05,
      size.height * 0.6,
      size.width * 0.85,
      size.height * 0.9,
      size.width * 0.45,
      size.height * 0.95,
    );
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.9,
      0,
      size.height * 0.6,
      0,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      0.05,
      size.height * 0.1,
      size.width * 0.4,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated top-right main blob with wiggle effect
class _TopRightBlobPainter extends CustomPainter {
  final Animation<double> animation;

  _TopRightBlobPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final wiggle = math.sin(animation.value * 2 * math.pi) * 10;
    final opacity = 0.8 + (math.cos(animation.value * 2 * math.pi) * 0.15);

    final paint = Paint()..style = PaintingStyle.fill;
    final color1 = AppColors.blue.withOpacity(0.7);
    final color2 = AppColors.blue.withOpacity(0.5);

    paint.shader = LinearGradient(
      colors: [color1.withOpacity(opacity), color2.withOpacity(opacity * 0.9)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.translate(wiggle, wiggle * 0.5);

    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.quadraticBezierTo(
        size.width * 0.9, 0.05, size.width, size.height * 0.3);
    path.cubicTo(
      size.width * 1.05,
      size.height * 0.7,
      size.width * 0.85,
      size.height * 0.95,
      size.width * 0.5,
      size.height * 0.85,
    );
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.7,
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.2,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated bottom-left main blob with scale pulse
// ignore: unused_element
class _BottomLeftBlobPainter extends CustomPainter {
  final Animation<double> animation;

  _BottomLeftBlobPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = 1.0 + (math.cos(animation.value * 2 * math.pi) * 0.12);
    final opacity = 0.75 + (math.sin(animation.value * 2 * math.pi + 1) * 0.2);

    final paint = Paint()..style = PaintingStyle.fill;
    final color1 = AppColors.blue.withOpacity(0.6);
    final color2 = AppColors.blue.withOpacity(0.8);

    paint.shader = LinearGradient(
      colors: [color1.withOpacity(opacity), color2.withOpacity(opacity * 0.85)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.scale(scale, scale);

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.4);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.05,
      size.width * 0.7,
      size.height * 0.05,
      size.width * 0.9,
      size.height * 0.4,
    );
    path.cubicTo(
      size.width * 1.0,
      size.height * 0.75,
      size.width * 0.7,
      size.height * 1.0,
      size.width * 0.3,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      -0.05,
      size.height * 0.65,
      size.width * 0.1,
      size.height * 0.4,
    );
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated illustration background with rotation
class _IllustrationBgPainter extends CustomPainter {
  final Animation<double> animation;

  _IllustrationBgPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rotation = -0.1745 + (math.sin(animation.value * 2 * math.pi) * 0.05);
    final opacity = 0.4 + (math.cos(animation.value * 2 * math.pi) * 0.15);

    final paint = Paint()
      ..color = AppColors.blue.withOpacity(0.4).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    const rectSize = 400.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: rectSize,
        height: rectSize,
      ),
      const Radius.circular(50),
    );

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =======================================================================
// ANIMATED MAIN WIDGET
// =======================================================================

class LandingBackground extends StatefulWidget {
  const LandingBackground({super.key});

  @override
  State<LandingBackground> createState() => _LandingBackgroundState();
}

class _LandingBackgroundState extends State<LandingBackground>
    with TickerProviderStateMixin {
  late AnimationController _blobController;
  late AnimationController _decorController;

  @override
  void initState() {
    super.initState();

    _blobController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _decorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    _decorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              // // Animated top-left blob
              // Positioned(
              //   top: -size.height * 0.15,
              //   left: -size.width * 0.1,
              //   child: AnimatedBuilder(
              //     animation: _blobController,
              //     builder: (context, child) {
              //       return CustomPaint(
              //         size: const Size(550, 450),
              //         painter: _TopLeftBlobPainter(_blobController),
              //       );
              //     },
              //   ),
              // ),

              // Animated top-right blob
              Positioned(
                top: -size.height * 0.1,
                right: -size.width * 0.12,
                child: AnimatedBuilder(
                  animation: _blobController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(650, 600),
                      painter: _TopRightBlobPainter(_blobController),
                    );
                  },
                ),
              ),

              // // Animated bottom-left blob
              // Positioned(
              //   bottom: -size.height * 0.25,
              //   left: -size.width * 0.15,
              //   child: AnimatedBuilder(
              //     animation: _blobController,
              //     builder: (context, child) {
              //       return CustomPaint(
              //         size: const Size(500, 550),
              //         painter: _BottomLeftBlobPainter(_blobController),
              //       );
              //     },
              //   ),
              // ),

              // Animated center illustration background
              Positioned(
                top: size.height * 0.15,
                right: size.width * 0.05,
                child: AnimatedBuilder(
                  animation: _blobController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(450, 450),
                      painter: _IllustrationBgPainter(_blobController),
                    );
                  },
                ),
              ),

              // Animated decorative circles
              _buildAnimatedCircle(
                size.height * 0.38,
                size.width * 0.1,
                18,
                AppColors.blue.withOpacity(0.7),
              ),

              _buildAnimatedCircle(
                size.height * 0.4,
                size.width * 0.17,
                20,
                AppColors.blue.withOpacity(0.6),
                bottom: true,
              ),
              _buildAnimatedCircle(
                size.height * 0.28,
                size.width * 0.07,
                22,
                AppColors.blue.withOpacity(0.4),
                bottom: true,
                right: true,
              ),
              _buildAnimatedCircle(
                size.height * 0.16,
                size.width * 0.38,
                14,
                AppColors.blue.withOpacity(0.8),
                right: true,
              ),

              // Animated diagonal lines
              _buildAnimatedDiagonalLines(
                size.height * 0.12,
                size.width * 0.27,
                70,
                95,
                AppColors.blue.withOpacity(0.4),
                right: true,
              ),
              _buildAnimatedDiagonalLines(
                size.height * 0.48,
                size.width * 0.08,
                65,
                85,
                AppColors.blue.withOpacity(0.6),
                bottom: true,
              ),
              _buildAnimatedDiagonalLines(
                size.height * 0.25,
                size.width * 0.32,
                60,
                80,
                AppColors.blue.withOpacity(0.5),
                bottom: true,
              ),

              // Animated dot grids
              _buildAnimatedDotGrid(
                size.height * 0.52,
                size.width * 0.18,
                AppColors.blue.withOpacity(0.7),
              ),
              _buildAnimatedDotGrid(
                size.height * 0.15,
                size.width * 0.45,
                AppColors.blue.withOpacity(0.5),
                bottom: true,
                right: true,
              ),

              // Animated squares
              _buildAnimatedSquare(
                size.height * 0.17,
                size.width * 0.19,
                11,
                AppColors.blue.withOpacity(0.4),
              ),
              _buildAnimatedSquare(
                size.height * 0.55,
                size.width * 0.05,
                9,
                AppColors.blue.withOpacity(0.6),
                bottom: true,
              ),
              _buildAnimatedSquare(
                size.height * 0.08,
                size.width * 0.1,
                13,
                AppColors.blue.withOpacity(0.3),
                right: true,
              ),
              _buildAnimatedSquare(
                size.height * 0.35,
                size.width * 0.05,
                12,
                AppColors.blue.withOpacity(0.5),
                bottom: true,
                right: true,
              ),
              _buildAnimatedSquare(
                size.height * 0.28,
                size.width * 0.55,
                10,
                AppColors.blue.withOpacity(0.7),
                right: true,
              ),

              // Animated horizontal line
              _buildAnimatedHorizontalLine(
                size.height * 0.54,
                size.width * 0.15,
                size.width * 0.12,
                AppColors.blue.withOpacity(0.3),
                bottom: true,
              ),

              // Small accent circle
              _buildAnimatedCircle(
                size.height * 0.25,
                size.width * 0.08,
                12,
                AppColors.blue.withOpacity(0.4),
                right: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCircle(
    double position,
    double offset,
    double size,
    Color color, {
    bool bottom = false,
    bool right = false,
  }) {
    return Positioned(
      top: !bottom ? position : null,
      bottom: bottom ? position : null,
      left: right ? offset : null,
      right: !right ? offset : null,
      child: AnimatedBuilder(
        animation: _decorController,
        builder: (context, child) {
          final scale =
              1.0 + (math.sin(_decorController.value * 2 * math.pi) * 0.15);
          final opacity =
              0.7 + (math.cos(_decorController.value * 2 * math.pi) * 0.3);
          return Transform.scale(
            scale: scale,
            child: _CircleDecoration(
              size: size,
              color: color.withOpacity(opacity),
              filled: false,
              strokeWidth: 2.5,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedDiagonalLines(
    double position,
    double offset,
    double width,
    double height,
    Color color, {
    bool bottom = false,
    bool right = false,
  }) {
    return Positioned(
      top: !bottom ? position : null,
      bottom: bottom ? position : null,
      left: !right ? offset : null,
      right: right ? offset : null,
      child: AnimatedBuilder(
        animation: _decorController,
        builder: (context, child) {
          final opacity = 0.25 +
              (math.sin(_decorController.value * 2 * math.pi + 0.5) * 0.2);
          return Opacity(
            opacity: opacity,
            child: _DiagonalLines(
              width: width,
              height: height,
              color: color,
              lineCount: 9,
              strokeWidth: 2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedDotGrid(
    double position,
    double offset,
    Color color, {
    bool bottom = false,
    bool right = false,
  }) {
    return Positioned(
      top: !bottom ? position : null,
      bottom: bottom ? position : null,
      left: !right ? offset : null,
      right: right ? offset : null,
      child: AnimatedBuilder(
        animation: _decorController,
        builder: (context, child) {
          final scale =
              1.0 + (math.cos(_decorController.value * 2 * math.pi + 1) * 0.2);
          final opacity =
              0.3 + (math.sin(_decorController.value * 2 * math.pi) * 0.25);
          return Transform.scale(
            scale: scale,
            child: _DotGrid(
              rows: 3,
              columns: 3,
              dotSize: 4.5,
              spacing: 14,
              color: color.withOpacity(opacity),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedSquare(
    double position,
    double offset,
    double size,
    Color color, {
    bool bottom = false,
    bool right = false,
  }) {
    return Positioned(
      top: !bottom ? position : null,
      bottom: bottom ? position : null,
      left: !right ? offset : null,
      right: right ? offset : null,
      child: AnimatedBuilder(
        animation: _decorController,
        builder: (context, child) {
          final rotation = math.sin(_decorController.value * 2 * math.pi) * 0.1;
          final opacity = 0.35 +
              (math.cos(_decorController.value * 2 * math.pi + 0.8) * 0.25);
          return Transform.rotate(
            angle: rotation,
            child: _SquareDecoration(
              size: size,
              color: color.withOpacity(opacity),
              strokeWidth: 2.5,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHorizontalLine(
    double position,
    double offset,
    double width,
    Color color, {
    bool bottom = false,
  }) {
    return Positioned(
      top: !bottom ? position : null,
      bottom: bottom ? position : null,
      left: offset,
      child: AnimatedBuilder(
        animation: _decorController,
        builder: (context, child) {
          final opacity = 0.25 +
              (math.sin(_decorController.value * 2 * math.pi + 1.2) * 0.2);
          return Opacity(
            opacity: opacity,
            child: _HorizontalLine(
              width: width,
              color: color,
              strokeWidth: 2,
            ),
          );
        },
      ),
    );
  }
}

// =======================================================================
// STATIC DECORATION WIDGETS
// =======================================================================

class _CircleDecoration extends StatelessWidget {
  final double size;
  final Color color;
  final bool filled;
  final double strokeWidth;

  const _CircleDecoration({
    required this.size,
    required this.color,
    this.filled = true,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: strokeWidth),
      ),
    );
  }
}

class _DiagonalLines extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final int lineCount;
  final double strokeWidth;

  const _DiagonalLines({
    required this.width,
    required this.height,
    required this.color,
    this.lineCount = 8,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _DiagonalLinesPainter(
        color: color,
        lineCount: lineCount,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _DiagonalLinesPainter extends CustomPainter {
  final Color color;
  final int lineCount;
  final double strokeWidth;

  _DiagonalLinesPainter({
    required this.color,
    required this.lineCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final spacing = size.width / (lineCount - 1);

    for (int i = 0; i < lineCount; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotGrid extends StatelessWidget {
  final int rows;
  final int columns;
  final double dotSize;
  final double spacing;
  final Color color;

  const _DotGrid({
    required this.rows,
    required this.columns,
    required this.dotSize,
    required this.spacing,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (columns - 1) * spacing + dotSize,
      height: (rows - 1) * spacing + dotSize,
      child: CustomPaint(
        painter: _DotGridPainter(
          rows: rows,
          columns: columns,
          dotSize: dotSize,
          spacing: spacing,
          color: color,
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final double dotSize;
  final double spacing;
  final Color color;

  _DotGridPainter({
    required this.rows,
    required this.columns,
    required this.dotSize,
    required this.spacing,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final x = col * spacing + dotSize / 2;
        final y = row * spacing + dotSize / 2;
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SquareDecoration extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const _SquareDecoration({
    required this.size,
    required this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: color, width: strokeWidth),
      ),
    );
  }
}

class _HorizontalLine extends StatelessWidget {
  final double width;
  final Color color;
  final double strokeWidth;

  const _HorizontalLine({
    required this.width,
    required this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: strokeWidth,
      color: color,
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class HeartAnimation extends StatefulWidget {
  final int heartCount;
  final Duration duration;

  const HeartAnimation({
    super.key,
    this.heartCount = 20,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with TickerProviderStateMixin {
  final List<HeartParticle> _hearts = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Kalpleri oluştur
    for (int i = 0; i < widget.heartCount; i++) {
      _hearts.add(HeartParticle(
        startX: math.Random().nextDouble(),
        startY: 1.0,
        delay: i * 0.1,
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: HeartPainter(_hearts, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class HeartParticle {
  final double startX;
  final double startY;
  final double delay;
  final double speed = math.Random().nextDouble() * 0.5 + 0.3;
  final double horizontalDrift = (math.Random().nextDouble() - 0.5) * 0.3;

  HeartParticle({
    required this.startX,
    required this.startY,
    required this.delay,
  });
}

class HeartPainter extends CustomPainter {
  final List<HeartParticle> hearts;
  final double progress;

  HeartPainter(this.hearts, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF69B4)
      ..style = PaintingStyle.fill;

    for (final heart in hearts) {
      final adjustedProgress = math.max(0, progress - heart.delay);
      if (adjustedProgress > 0 && adjustedProgress < 1) {
        final y = heart.startY - (adjustedProgress * heart.speed);
        final x = heart.startX + (adjustedProgress * heart.horizontalDrift);

        if (y > 0 && y < 1) {
          _drawHeart(
            canvas,
            Offset(x * size.width, y * size.height),
            size.width * 0.05 * (1 - adjustedProgress),
            paint,
          );
        }
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5,
      center.dy - size * 0.2,
      center.dx - size,
      center.dy - size * 0.5,
      center.dx,
      center.dy - size,
    );
    path.cubicTo(
      center.dx + size,
      center.dy - size * 0.5,
      center.dx + size * 0.5,
      center.dy - size * 0.2,
      center.dx,
      center.dy + size * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) => true;
}


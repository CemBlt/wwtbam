import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart' as confetti;
import 'dart:math' as math;

class ConfettiAnimation extends StatefulWidget {
  final bool isActive;
  final Color? color;

  const ConfettiAnimation({
    super.key,
    required this.isActive,
    this.color,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation> {
  late confetti.ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = confetti.ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: confetti.ConfettiWidget(
        confettiController: _controller,
        blastDirection: math.pi / 2,
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.1,
        colors: widget.color != null
            ? [widget.color!]
            : const [
                Color(0xFFFF69B4),
                Color(0xFFFF1493),
                Color(0xFFFFD700),
                Color(0xFFFFB6C1),
              ],
      ),
    );
  }
}


import 'dart:math';
import 'package:flutter/material.dart';

class RainDrop {
  Offset position;
  double speed;

  RainDrop(this.position, this.speed);
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final Paint paintDrop;

  RainPainter(this.drops)
      : paintDrop = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    for (var drop in drops) {
      canvas.drawLine(
        drop.position,
        drop.position + Offset(0, 8),
        paintDrop,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

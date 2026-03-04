// ─── Arc Painter ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final bool isGoalMet;

  ArcPainter({required this.progress, required this.accentColor, required this.isGoalMet});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;
    const startAngle = -math.pi / 2;

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    if (progress > 0) {
      final fillPaint = Paint()
        ..color = isGoalMet ? const Color(0xFF4A5568) : const Color(0xFF4A5568)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        fillPaint,
      );
    }

    // Milestone ticks every 10
    final tickPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 1; i < 10; i++) {
      final angle = startAngle + 2 * math.pi * (i / 10);
      final inner = Offset(
        center.dx + (radius - 6) * math.cos(angle),
        center.dy + (radius - 6) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (radius + 6) * math.cos(angle),
        center.dy + (radius + 6) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(ArcPainter old) => old.progress != progress || old.isGoalMet != isGoalMet;
}

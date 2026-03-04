import 'dart:math' as math;

import 'package:dhikir_app/widgets/arc_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CounterButton extends StatelessWidget {
  final int count;
  final int target;
  final double progress;
  final bool isGoalMet;
  final bool isUnlimited;
  final Color accentColor;
  final Animation<double> pulseAnim;
  final Animation<double> completionAnim;
  final VoidCallback onTap;

  const CounterButton({
    super.key,
    required this.count,
    required this.target,
    required this.progress,
    required this.isGoalMet,
    required this.isUnlimited,
    required this.accentColor,
    required this.pulseAnim,
    required this.completionAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulseAnim, completionAnim]),
        builder: (context, child) {
          final scale = pulseAnim.value * (isGoalMet ? (1.0 + 0.06 * math.sin(completionAnim.value * math.pi)) : 1.0);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring (goal met)
              if (isGoalMet)
                AnimatedBuilder(
                  animation: completionAnim,
                  builder: (_, __) => Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

              // Arc progress painter
              CustomPaint(
                size: const Size(200, 200),
                painter: ArcPainter(
                  progress: progress,
                  accentColor: accentColor,
                  isGoalMet: isGoalMet,
                ),
              ),

              // Inner circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isGoalMet ? accentColor : const Color(0xFFF6F4F1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isGoalMet)
                      const Icon(Icons.check_rounded, size: 28, color: Color(0xFF2D3748))
                    else ...[
                      Text(
                        '$count',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3748),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUnlimited ? 'of ∞' : 'of $target',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                    if (isGoalMet) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$count',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

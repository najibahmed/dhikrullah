import 'dart:math' as math;

import 'package:dhikir_app/core/widgets/arc_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/theme/theme_colors.dart';

class CounterButton extends StatelessWidget {
  final int count;
  final int target;
  final double progress;
  final bool isGoalMet;
  final bool isUnlimited;
  final Color accentColor;
  final Animation<double> pulseAnim;
  final Animation<double> completionAnim;
  final VoidCallback? onTap;

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
    final colorScheme = Theme.of(context).colorScheme;
    final onAccent = onColorFor(accentColor);
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
                  trackColor: colorScheme.outlineVariant,
                ),
              ),

              // Inner circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isGoalMet ? accentColor : colorScheme.surfaceContainerHighest,
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
                      Icon(Icons.check_rounded, size: 28, color: onAccent)
                    else ...[
                      Text(
                        '$count',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUnlimited
                            ? context.l10n.ofUnlimited
                            : context.l10n.ofTarget(target),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
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
                          color: onAccent,
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

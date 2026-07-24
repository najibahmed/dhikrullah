// ─── Milestone Dots ───────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:dhikir_app/core/theme/theme_colors.dart';

class MilestoneDots extends StatelessWidget {
  final int count;
  final int target;
  final Color accentColor;

  const MilestoneDots({super.key, required this.count, required this.target, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onAccent = onColorFor(accentColor);
    // 10 dots = 10 milestones of 10
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (i) {
        final milestone = (i + 1) * 10;
        final reached = count >= milestone;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: reached ? 14 : 10,
          height: reached ? 14 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: reached ? accentColor : colorScheme.outlineVariant,
          ),
          child: reached ? Icon(Icons.check_rounded, size: 8, color: onAccent) : null,
        );
      }),
    );
  }
}

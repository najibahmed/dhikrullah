// ─── Milestone Dots ───────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class MilestoneDots extends StatelessWidget {
  final int count;
  final int target;
  final Color accentColor;

  const MilestoneDots({super.key, required this.count, required this.target, required this.accentColor});

  @override
  Widget build(BuildContext context) {
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
            color: reached ? const Color(0xFF4A5568) : const Color(0xFFE2E8F0),
          ),
          child: reached ? const Icon(Icons.check_rounded, size: 8, color: Colors.white) : null,
        );
      }),
    );
  }
}

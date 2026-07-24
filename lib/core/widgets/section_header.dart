import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onSession;

  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.onSession,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillColor = isDark ? const Color(0xFF2A2C40) : const Color(0xFFE8EAF6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
        GestureDetector(
          onTap: onSession,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.play_arrow_rounded, size: 12, color: colorScheme.primary),
                const SizedBox(width: 3),
                Text(context.l10n.sessionCountLabel(count), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

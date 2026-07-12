import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
        GestureDetector(
          onTap: onSession,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_arrow_rounded, size: 12, color: Color(0xFF4A5568)),
                const SizedBox(width: 3),
                Text('Session ($count)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4A5568))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

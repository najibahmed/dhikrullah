import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Pill extends StatelessWidget {
  final String label;
  final Color color;
  const Pill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4A5568))),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool bordered;
  const LegendDot({super.key, required this.color, required this.label, this.bordered = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: bordered ? Border.all(color: const Color(0xFFCBD5E0), width: 1) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF718096))),
      ],
    );
  }
}

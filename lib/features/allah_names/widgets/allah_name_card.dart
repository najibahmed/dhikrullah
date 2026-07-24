import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/providers/font_size_provider.dart';
import 'package:dhikir_app/core/theme/theme_colors.dart';
import 'package:dhikir_app/features/allah_names/models/allah_name.dart';

const List<String> _palette = [
  '#E8F5E9',
  '#E3F2FD',
  '#FFF3E0',
  '#F3E5F5',
  '#E0F7FA',
  '#FFF8E1',
  '#FCE4EC',
  '#E8EAF6',
  '#F1F8E9',
  '#E0F2F1',
  '#FBE9E7',
  '#EDE7F6',
];

Color _colorForNumber(int number) {
  final hex = _palette[number % _palette.length];
  return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
}

class AllahNameCard extends StatelessWidget {
  final AllahName name;

  const AllahNameCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final fontSize = context.watch<FontSizeProvider>();
    final bgColor = adjustForBrightness(_colorForNumber(name.number), Theme.of(context).brightness);
    final onBg = onColorFor(bgColor);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: AlignmentGeometry.center,
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  child: Text(
                    '${name.number}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: onBg,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentGeometry.center,
                child: Text(
                  name.arabic,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: fontSize.arabicFontSize,
                    fontWeight: FontWeight.w800,
                    color: onBg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name.transliteration,
            style: GoogleFonts.inter(
              fontSize: fontSize.transliterationFontSize,
              fontWeight: FontWeight.w700,
              color: onBg,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.english,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: onBg.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name.meaning,
            style: GoogleFonts.inter(
              fontSize: fontSize.meaningFontSize,
              height: 1.4,
              color: onBg.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

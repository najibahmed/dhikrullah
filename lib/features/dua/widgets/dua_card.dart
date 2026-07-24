import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/providers/font_size_provider.dart';
import 'package:dhikir_app/core/theme/theme_colors.dart';
import 'package:dhikir_app/features/dua/models/dua_item.dart';

/// Single dua card — shows every field (title, arabic, transliteration,
/// translation, source, repeat count) always expanded, per the minimalist
/// "all information at once" design for the dua list.
class DuaCard extends StatelessWidget {
  final DuaItem dua;
  final String categoryName;

  const DuaCard({super.key, required this.dua, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fontSize = context.watch<FontSizeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dua.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (dua.repeat > 1) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: mintAccentBackground(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.duaRepeatLabel(dua.repeat),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dua.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: fontSize.arabicFontSize,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dua.transliteration,
            style: GoogleFonts.inter(
              fontSize: fontSize.transliterationFontSize,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dua.translation,
            style: GoogleFonts.inter(
              fontSize: fontSize.meaningFontSize,
              height: 1.45,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "— ${dua.source}",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

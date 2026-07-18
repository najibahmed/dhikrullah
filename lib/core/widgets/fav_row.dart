import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/core/data/dhikir_localizations.dart';

class FavRow extends StatelessWidget {
  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String icon;
  final String colorHex;
  final VoidCallback onSession;
  final VoidCallback? onToggleFav;

  const FavRow({
    super.key,
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.icon,
    required this.colorHex,
    required this.onSession,
    this.onToggleFav,
  });

  Color get _color => Color(int.parse(colorHex.replaceFirst('#', 'FF'), radix: 16));

  @override
  Widget build(BuildContext context) {
    final builtInFavIds = HiveService.builtInFavoriteIds.toSet();
    final myFavorites = CustomDhikirService.getFavorites();
    final myFavoritesIds = myFavorites.map((d) => d.id).toList();
    final isFav = [...builtInFavIds, ...myFavoritesIds].contains(id);
    return GestureDetector(
      onTap: onSession,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(arabic,
                  //     style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748)),
                  //     textDirection: TextDirection.rtl,
                  //     overflow: TextOverflow.ellipsis),
                  Text(localizedDhikirTitle(context, id) ?? title,
                      style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4A5568))),
                  Text(localizedDhikirTransliteration(context, id) ?? transliteration,
                      style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: const Color(0xFF718096)),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onToggleFav,
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 22,
                color: isFav ? const Color(0xFFFC8181) : const Color(0xFFCBD5E0),
              ),
            ),
            const SizedBox(width: 8),
            // GestureDetector(
            //   onTap: onSession,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            //     // decoration: BoxDecoration(
            //     //   color: const Color(0xFF2D3748),
            //     //   borderRadius: BorderRadius.circular(8),
            //     // ),
            //     child: const Icon(Icons.play_arrow_rounded, size: 26, color: Colors.black),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

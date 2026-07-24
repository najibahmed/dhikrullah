import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/theme/app_colors.dart';

/// Full-page navigation tile for a dua category (title, description, count).
/// Plain tap-to-navigate row — no selected state, unlike a filter picker.
class DuaCategoryTile extends StatelessWidget {
  final String title;
  final String description;
  final int count;
  final VoidCallback onTap;

  const DuaCategoryTile({
    super.key,
    required this.title,
    required this.description,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mintBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                      Text(
                        l10n.duaCountLabel(count),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.subtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.medium),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/theme/app_colors.dart';
import 'package:dhikir_app/features/dua/models/dua_item.dart';

/// Bottom sheet for picking a single dua category to filter by.
/// `null` selection/result means "All". Tapping a row selects it and
/// immediately closes the sheet (single-select, no separate confirm step).
Future<String?> showDuaCategorySheet(
  BuildContext context, {
  required List<DuaCategory> categories,
  required String? selected,
  required int totalCount,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DuaCategorySheet(
      categories: categories,
      selected: selected,
      totalCount: totalCount,
    ),
  );
}

class _DuaCategorySheet extends StatelessWidget {
  final List<DuaCategory> categories;
  final String? selected;
  final int totalCount;

  const _DuaCategorySheet({
    required this.categories,
    required this.selected,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.duaCategorySheetTitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    _CategoryRow(
                      title: l10n.duaCategoryAll,
                      description: l10n.duaCategoryAllDescription,
                      count: totalCount,
                      isSelected: selected == null,
                      onTap: () => Navigator.pop(context, null),
                    ),
                    const SizedBox(height: 8),
                    for (final category in categories) ...[
                      _CategoryRow(
                        title: category.name,
                        description: category.description,
                        count: category.count,
                        isSelected: selected == category.id,
                        onTap: () => Navigator.pop(context, category.id),
                      ),
                      const SizedBox(height: 8),
                    ],
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

class _CategoryRow extends StatelessWidget {
  final String title;
  final String description;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.title,
    required this.description,
    required this.count,
    required this.isSelected,
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
          color: isSelected
              ? AppColors.accentMint.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.mintBorder : Colors.transparent,
            width: 1.5,
          ),
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
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  size: 18, color: AppColors.medium),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Goal Picker Bottom Sheet ────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/theme/theme_colors.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

class GoalPickerSheet extends StatefulWidget {
  final int currentTarget;
  final Color accentColor;
  final List<int> goalOptions;

  const GoalPickerSheet({
    super.key,
    required this.currentTarget,
    required this.accentColor,
    required this.goalOptions,
  });

  @override
  State<GoalPickerSheet> createState() => _GoalPickerSheetState();
}

class _GoalPickerSheetState extends State<GoalPickerSheet> {
  late int _selected;

  static const _labels = {
    33: '33',
    34: '34',
    99: '99',
    100: '100',
    -1: '∞',
  };

  @override
  void initState() {
    super.initState();
    _selected = widget.currentTarget;
  }

  String _label(int v) => _labels[v] ?? '$v';

  String _subtitle(AppLocalizations l10n, int v) => switch (v) {
        33 => l10n.goalSubtitleTasbihSubhanallah,
        34 => l10n.goalSubtitleTasbihAlhamdulillah,
        99 => l10n.goalSubtitleNamesOfAllah,
        100 => l10n.goalSubtitleDailyCentury,
        -1 => l10n.goalSubtitleNoLimit,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = widget.accentColor;
    final onAccent = onColorFor(accent);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.flag_rounded, size: 20, color: onAccent),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.goalPickSheetTitle,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          l10n.goalPickSheetSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Goal option buttons
                ...widget.goalOptions.map((goal) {
                  final isSelected = _selected == goal;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = goal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: colorScheme.primary, width: 0)
                            : Border.all(color: colorScheme.outlineVariant, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          // Goal number badge
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected ? accent : colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow:
                                  isSelected ? [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))] : [],
                            ),
                            child: Center(
                              child: Text(
                                _label(goal),
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: goal == -1 ? 26 : 20,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? onAccent : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Labels
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal == -1 ? l10n.goalLabelUnlimited : l10n.goalLabelTimes(goal),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _subtitle(l10n, goal),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isSelected
                                        ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Check indicator
                          AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check_rounded, size: 14, color: onAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // Action buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, null),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              l10n.commonCancel,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Set goal
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, _selected),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag_rounded, size: 16, color: colorScheme.onPrimary),
                                const SizedBox(width: 8),
                                Text(
                                  _selected == -1
                                      ? l10n.setUnlimitedButton
                                      : l10n.setGoalButton(_label(_selected)),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

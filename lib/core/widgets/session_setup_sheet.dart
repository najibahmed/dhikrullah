// lib/core/widgets/session_setup_sheet.dart
//
// Goal-picker bottom sheet shown before starting a counter session.
// Shared by the dhikir (home), my-dhikir, and favorites features, so it
// lives in core/widgets rather than any single feature folder.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/data/dhikir_localizations.dart';
import 'package:dhikir_app/core/theme/theme_colors.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

class SessionSetupSheet extends StatefulWidget {
  final List<SessionDhikir> dhikirList;
  final void Function(int goal) onStart;

  const SessionSetupSheet({super.key, required this.dhikirList, required this.onStart});

  @override
  State<SessionSetupSheet> createState() => SessionSetupSheetState();
}

class SessionSetupSheetState extends State<SessionSetupSheet> {
  int _goal = 100;

  static const _goals = [33, 34, 99, 100, -1];
  static const _labels = {33: '33', 34: '34', 99: '99', 100: '100', -1: '∞'};

  String _descFor(AppLocalizations l10n, int g) => switch (g) {
        33 => l10n.setupGoalDescSubhanallah,
        34 => l10n.setupGoalDescAlhamdulillah,
        99 => l10n.goalSubtitleNamesOfAllah,
        100 => l10n.setupGoalDescCenturyGoal,
        -1 => l10n.setupGoalDescNoLimit,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.play_circle_rounded, size: 22, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.setupSheetTitle,
                          style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                      Text(l10n.setupSheetSubtitle(widget.dhikirList.length),
                          style: GoogleFonts.inter(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.setupGoalPerDhikir, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                children: _goals.map((g) {
                  final isSelected = _goal == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _goal = g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? null : Border.all(color: colorScheme.outlineVariant, width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _labels[g]!,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: g == -1 ? 18 : 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _descFor(l10n, g),
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                color: isSelected ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Dhikir preview chips
              Text(l10n.setupSessionIncludes, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.dhikirList.map((d) {
                  final chipColor = adjustForBrightness(d.color, brightness);
                  final onChip = onColorFor(chipColor);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(d.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(localizedDhikirTitle(context, d.id) ?? d.title,
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: onChip)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
                        ),
                        child: Center(
                          child: Text(l10n.commonCancel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => widget.onStart(_goal),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: colorScheme.onPrimary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _goal == -1
                                  ? l10n.setupStartUnlimited
                                  : l10n.setupStartGoal(_labels[_goal]!),
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onPrimary),
                            ),
                          ],
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
    );
  }
}

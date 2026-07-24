// lib/screens/dhikir_calendar_screen.dart
//
// Calendar history screen for a single dhikir.
//
// Provider/Consumer strategy — only the minimum subtree rebuilds:
//   • _StatsCard       → progress change (day toggle, reset, month switch)
//   • _CalendarCard    → progress change + month navigation
//   • _YearHeatmap     → focused month highlight + progress totals
//   • _ResetButton     → month name label only
//   • App bar title    → never rebuilds (static, outside Consumer)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/theme/theme_colors.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/data/dhikir_localizations.dart';
import 'package:dhikir_app/features/dhikir/providers/dhikir_calendar_provider.dart';

String _fullMonthName(BuildContext context, int year, int month) => DateFormat(
        'MMMM', Localizations.localeOf(context).toString())
    .format(DateTime(year, month));

String _shortMonthName(BuildContext context, int year, int month) =>
    DateFormat('MMM', Localizations.localeOf(context).toString())
        .format(DateTime(year, month));

/// [weekdayIndexSunFirst]: 0=Sun .. 6=Sat. Jan 1 2023 was a Sunday, used
/// purely as a reference date to format a locale-aware weekday label.
String _shortWeekday(BuildContext context, int weekdayIndexSunFirst) {
  final date = DateTime(2023, 1, 1).add(Duration(days: weekdayIndexSunFirst));
  return DateFormat('E', Localizations.localeOf(context).toString())
      .format(date);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DhikirCalendarScreen extends StatelessWidget {
  final DhikirItem dhikir;

  const DhikirCalendarScreen({super.key, required this.dhikir});

  Color get _accent => Color(int.parse(dhikir.colorHex.replaceFirst('#', 'FF'), radix: 16));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localizedTitle = localizedDhikirTitle(context, dhikir.id) ?? dhikir.title;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = adjustForBrightness(_accent, Theme.of(context).brightness);
    return ChangeNotifierProvider(
      // Scoped to this screen; auto-disposed when screen is popped.
      create: (_) => DhikirCalendarProvider(dhikir.id),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App bar — outside Consumer, never rebuilds ──────────────
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Column(
                  children: [
                    Text(
                      localizedTitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      l10n.calendarTitle,
                      style: GoogleFonts.inter(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                centerTitle: true,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      // Stats card — rebuilds on every progress or month change.
                      Consumer<DhikirCalendarProvider>(
                        builder: (_, cal, __) => _StatsCard(
                          dhikir: dhikir,
                          accentColor: accentColor,
                          completedCount: cal.completedCount,
                          daysInMonth: cal.daysInMonth,
                          pct: cal.completionPct,
                          currentStreak: cal.currentStreak,
                          longestStreak: cal.longestStreak,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Calendar (navigator + grid + legend).
                      // Month nav and day cells share the same Consumer
                      // to avoid nested provider reads.
                      Consumer<DhikirCalendarProvider>(
                        builder: (_, cal, __) => _CalendarCard(
                          cal: cal,
                          accentColor: accentColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Heatmap — rebuilds when focused month or totals change.
                      Consumer<DhikirCalendarProvider>(
                        builder: (_, cal, __) => _YearHeatmap(
                          progress: cal.progress,
                          focusedMonth: cal.focusedMonth,
                          accentColor: accentColor,
                          onMonthTap: cal.jumpTo,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Reset button — only needs the month name label.
                      Consumer<DhikirCalendarProvider>(
                        builder: (_, cal, __) => _ResetButton(
                          monthName: _fullMonthName(context, cal.year, cal.month),
                          onReset: () => _confirmReset(context, cal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog then delegates the reset to the provider.
  Future<void> _confirmReset(BuildContext context, DhikirCalendarProvider cal) async {
    final l10n = context.l10n;
    final monthName = _fullMonthName(context, cal.year, cal.month);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.resetMonthDialogTitle(monthName),
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.resetMonthDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.resetMonthButton),
          ),
        ],
      ),
    );
    if (ok == true) await cal.resetMonth();
  }
}

// ─── Calendar card (navigator + day grid + legend) ────────────────────────────

class _CalendarCard extends StatelessWidget {
  final DhikirCalendarProvider cal;
  final Color accentColor;

  const _CalendarCard({required this.cal, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigator row
          _MonthNavigator(
            monthName: _fullMonthName(context, cal.year, cal.month),
            year: cal.year,
            onPrev: cal.prevMonth,
            onNext: cal.canGoNext ? cal.nextMonth : null,
          ),

          // Weekday header row (static — no state dependency)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(7, (i) => i)
                  .map((i) => Expanded(
                        child: Center(
                          child: Text(
                            _shortWeekday(context, i),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: i == 5 ? const Color(0xFF48BB78) : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Day cell grid
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 2,
              children: _buildCells(),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: colorScheme.primary, label: l10n.legendCompleted),
                const SizedBox(width: 20),
                _Legend(color: accentColor, label: l10n.commonToday),
                const SizedBox(width: 20),
                _Legend(color: colorScheme.surfaceContainerHighest, label: l10n.legendMissed, bordered: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the flat list of leading empty spacers + day cell widgets.
  List<Widget> _buildCells() {
    final firstWeekday = DateTime(cal.year, cal.month, 1).weekday % 7;
    final today = DateTime.now();

    return [
      // Leading empty slots for day-of-week alignment
      for (int i = 0; i < firstWeekday; i++) const SizedBox(),

      // One cell per calendar day
      for (int d = 1; d <= cal.daysInMonth; d++)
        _CalendarCell(
          day: d,
          isCompleted: cal.completedDays.contains(d),
          isToday: cal.year == today.year && cal.month == today.month && d == today.day,
          isFuture: DateTime(cal.year, cal.month, d).isAfter(today),
          accentColor: accentColor,
          onTap: () => cal.toggleDay(d),
        ),
    ];
  }
}

// ─── Month navigator ──────────────────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  final String monthName;
  final int year;
  final VoidCallback onPrev;
  final VoidCallback? onNext; // null = disabled (current month)

  const _MonthNavigator({
    required this.monthName,
    required this.year,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Column(
            children: [
              Text(
                monthName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text('$year', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          _NavArrow(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

// ─── Stats card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final DhikirItem dhikir;
  final Color accentColor;
  final int completedCount;
  final int daysInMonth;
  final int pct;
  final int currentStreak;
  final int longestStreak;

  const _StatsCard({
    required this.dhikir,
    required this.accentColor,
    required this.completedCount,
    required this.daysInMonth,
    required this.pct,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onAccent = onColorFor(accentColor);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dhikir.arabicText,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: onAccent,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.monthSummary(completedCount, daysInMonth, pct),
                    style: GoogleFonts.inter(fontSize: 12, color: onAccent.withValues(alpha: 0.85)),
                  ),
                ],
              ),
              Text(dhikir.icon, style: const TextStyle(fontSize: 32)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: daysInMonth > 0 ? completedCount / daysInMonth : 0,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(onAccent),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(label: l10n.thisMonthLabel, value: l10n.daysCountLabel(completedCount)),
              const SizedBox(width: 8),
              _StatPill(label: l10n.statStreak, value: l10n.daysCountLabel(currentStreak)),
              const SizedBox(width: 8),
              _StatPill(label: l10n.statBest, value: l10n.daysCountLabel(longestStreak)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Year heatmap ─────────────────────────────────────────────────────────────

class _YearHeatmap extends StatelessWidget {
  final DhikirProgress progress;
  final DateTime focusedMonth;
  final Color accentColor;
  final void Function(int year, int month) onMonthTap;

  const _YearHeatmap({
    required this.progress,
    required this.focusedMonth,
    required this.accentColor,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final onAccent = onColorFor(accentColor);
    final year = focusedMonth.year;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.yearOverviewTitle,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '$year',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final m = i + 1;
              final daysInM = DateTime(year, m + 1, 0).day;
              final done = progress.completedCountInMonth(year, m);
              final ratio = daysInM > 0 ? done / daysInM : 0.0;
              final isFocused = focusedMonth.month == m;
              final isFuture = DateTime(year, m).isAfter(DateTime(today.year, today.month));

              return GestureDetector(
                onTap: isFuture ? null : () => onMonthTap(year, m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isFocused
                        ? colorScheme.primary
                        : isFuture
                            ? colorScheme.surfaceContainerHighest
                            : ratio > 0
                                ? accentColor.withValues(alpha: 0.3 + ratio * 0.7)
                                : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: isFocused ? Border.all(color: colorScheme.primary, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _shortMonthName(context, year, m),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isFocused
                              ? colorScheme.onPrimary
                              : isFuture
                                  ? colorScheme.outline
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (!isFuture) ...[
                        const SizedBox(height: 2),
                        Text(
                          done > 0 ? l10n.daysCountShort(done) : '–',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isFocused ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l10n.calendarFooter(progress.totalCompleted),
              style: GoogleFonts.inter(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reset button ─────────────────────────────────────────────────────────────

class _ResetButton extends StatelessWidget {
  final String monthName;
  final VoidCallback onReset;

  const _ResetButton({required this.monthName, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onReset,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
        ),
        child: Center(
          child: Text(
            context.l10n.resetMonthProgressButton(monthName),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Calendar cell ────────────────────────────────────────────────────────────

class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;
  final Color accentColor;
  final VoidCallback onTap;

  const _CalendarCell({
    required this.day,
    required this.isCompleted,
    required this.isToday,
    required this.isFuture,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // State priority: completed > today > future > missed
    final Color bg;
    final Color textColor;
    final BoxBorder? border;

    if (isCompleted) {
      bg = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      border = null;
    } else if (isToday) {
      bg = accentColor;
      textColor = onColorFor(accentColor);
      border = Border.all(color: colorScheme.primary, width: 1.5);
    } else if (isFuture) {
      bg = Colors.transparent;
      textColor = colorScheme.outline;
      border = null;
    } else {
      bg = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
      border = null;
    }

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
          border: border,
        ),
        child: Center(
          child: isCompleted
              ? Icon(Icons.check_rounded, size: 13, color: colorScheme.onPrimary)
              : Text(
                  '$day',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

/// Left/right arrow button for month navigation.
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap; // null = visually disabled

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? colorScheme.primary : colorScheme.outline,
        ),
      ),
    );
  }
}

/// Small colour swatch + label in the calendar legend row.
class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool bordered;

  const _Legend({
    required this.color,
    required this.label,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: bordered ? Border.all(color: colorScheme.outline, width: 1) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

/// Rounded pill showing a single stat value + label.
class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF718096)),
            ),
          ],
        ),
      ),
    );
  }
}


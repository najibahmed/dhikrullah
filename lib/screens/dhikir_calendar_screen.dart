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
import 'package:provider/provider.dart';

import '../models/dhikir_model.dart';
import '../providers/dhikir_calendar_provider.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class DhikirCalendarScreen extends StatelessWidget {
  final DhikirItem dhikir;

  const DhikirCalendarScreen({super.key, required this.dhikir});

  Color get _accent => Color(int.parse(dhikir.colorHex.replaceFirst('#', 'FF'), radix: 16));

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Scoped to this screen; auto-disposed when screen is popped.
      create: (_) => DhikirCalendarProvider(dhikir.id),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F4F1),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App bar — outside Consumer, never rebuilds ──────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFFF6F4F1),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Column(
                  children: [
                    Text(
                      dhikir.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'History Calendar',
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF718096)),
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
                          accentColor: _accent,
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
                          accentColor: _accent,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Heatmap — rebuilds when focused month or totals change.
                      Consumer<DhikirCalendarProvider>(
                        builder: (_, cal, __) => _YearHeatmap(
                          progress: cal.progress,
                          focusedMonth: cal.focusedMonth,
                          accentColor: _accent,
                          onMonthTap: cal.jumpTo,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Reset button — only needs the month name label.
                      Consumer<DhikirCalendarProvider>(
                        builder: (_, cal, __) => _ResetButton(
                          monthName: _kMonthNames[cal.month],
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset ${_kMonthNames[cal.month]}?',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        content: const Text('This clears all checkmarks for this month only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4A5568),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset Month'),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            monthName: _kMonthNames[cal.month],
            year: cal.year,
            onPrev: cal.prevMonth,
            onNext: cal.canGoNext ? cal.nextMonth : null,
          ),

          // Weekday header row (static — no state dependency)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _kWeekdays
                  .map((w) => Expanded(
                        child: Center(
                          child: Text(
                            w,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: w == 'Fri' ? const Color(0xFF48BB78) : const Color(0xFFA0AEC0),
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
                const _Legend(color: Color(0xFF4A5568), label: 'Completed'),
                const SizedBox(width: 20),
                _Legend(color: accentColor, label: 'Today'),
                const SizedBox(width: 20),
                const _Legend(color: Color(0xFFF0EEEb), label: 'Missed', bordered: true),
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
                  color: const Color(0xFF2D3748),
                ),
              ),
              Text('$year', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096))),
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
                      color: const Color(0xFF2D3748),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This month: $completedCount / $daysInMonth days ($pct%)',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF4A5568)),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A5568)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(label: 'This Month', value: '$completedCount days'),
              const SizedBox(width: 8),
              _StatPill(label: '🔥 Streak', value: '$currentStreak days'),
              const SizedBox(width: 8),
              _StatPill(label: 'Best', value: '$longestStreak days'),
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
    final year = focusedMonth.year;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                'Year Overview',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '$year',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748)),
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
                        ? const Color(0xFF4A5568)
                        : isFuture
                            ? const Color(0xFFF8F8F8)
                            : ratio > 0
                                ? accentColor.withValues(alpha: 0.3 + ratio * 0.7)
                                : const Color(0xFFF0EEEB),
                    borderRadius: BorderRadius.circular(12),
                    border: isFocused ? Border.all(color: const Color(0xFF2D3748), width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _kMonthShort[i],
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isFocused
                              ? Colors.white
                              : isFuture
                                  ? const Color(0xFFCBD5E0)
                                  : const Color(0xFF4A5568),
                        ),
                      ),
                      if (!isFuture) ...[
                        const SizedBox(height: 2),
                        Text(
                          done > 0 ? '$done d' : '–',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isFocused ? Colors.white70 : const Color(0xFF718096),
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
              'Tap a month to navigate  •  Total: ${progress.totalCompleted} days',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF718096)),
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
    return GestureDetector(
      onTap: onReset,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Center(
          child: Text(
            'Reset $monthName Progress',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF718096),
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
    // State priority: completed > today > future > missed
    final Color bg;
    final Color textColor;
    final BoxBorder? border;

    if (isCompleted) {
      bg = const Color(0xFF4A5568);
      textColor = Colors.white;
      border = null;
    } else if (isToday) {
      bg = accentColor;
      textColor = const Color(0xFF2D3748);
      border = Border.all(color: const Color(0xFF4A5568), width: 1.5);
    } else if (isFuture) {
      bg = Colors.transparent;
      textColor = const Color(0xFFCBD5E0);
      border = null;
    } else {
      bg = const Color(0xFFF0EEEB);
      textColor = const Color(0xFFA0AEC0);
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
              ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF6F4F1) : const Color(0xFFF0EEEB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF4A5568) : const Color(0xFFCBD5E0),
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

// ─── Constants ────────────────────────────────────────────────────────────────

const List<String> _kWeekdays = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];

/// Index 0 intentionally empty — months are 1-based.
const List<String> _kMonthNames = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _kMonthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

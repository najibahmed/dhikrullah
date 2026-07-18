// lib/core/widgets/date_header_row.dart
//
// Shared Gregorian + Hijri date display, used by the home dashboard and
// the prayer time detail screen. Pure display widget — the Hijri offset
// is passed in rather than read from PrayerTimeProvider directly, so this
// stays feature-agnostic per the core/ widgets convention.

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/utils/time_format.dart';
import 'package:intl/intl.dart';

String _formatGregorian(BuildContext context, DateTime date) {
  final localeName = Localizations.localeOf(context).toString();
  final weekday = DateFormat('EEEE', localeName).format(date);
  final month = DateFormat('MMMM', localeName).format(date);
  return '$weekday, ${date.day} $month ${date.year}';
}

class DateHeaderRow extends StatelessWidget {
  final int hijriOffsetDays;
  final DateTime? date;
  final DateTime? sunrise;
  final DateTime? sunset;
  final VoidCallback? onHijriTap;

  const DateHeaderRow({
    super.key,
    required this.hijriOffsetDays,
    this.date,
    this.sunrise,
    this.sunset,
    this.onHijriTap,
  });

  Widget _sunRow(
      BuildContext context, IconData icon, Color color, DateTime time) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          formatClockTime(time),
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = date ?? DateTime.now();
    final hijri = HijriCalendar.fromDate(
      now.add(Duration(days: hijriOffsetDays)),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                        '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}${context.l10n.hijriEraSuffix}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        )),
                    if (onHijriTap != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onHijriTap,
                        child: const Icon(Icons.link_outlined,
                            size: 18, color: Colors.black54),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatGregorian(context, now),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (sunrise != null && sunset != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _sunRow(
                    context, Icons.wb_sunny_outlined, Colors.amber, sunrise!),
                const SizedBox(height: 4),
                _sunRow(context, Icons.nightlight_round, Colors.deepOrange,
                    sunset!),
              ],
            ),
        ],
      ),
    );
  }
}

// lib/core/widgets/date_header_row.dart
//
// Shared Gregorian + Hijri date display, used by the home dashboard and
// the prayer time detail screen. Pure display widget — the Hijri offset
// is passed in rather than read from PrayerTimeProvider directly, so this
// stays feature-agnostic per the core/ widgets convention.

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _monthNames = [
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

String _formatGregorian(DateTime date) {
  final weekday = _weekdayNames[date.weekday - 1];
  final month = _monthNames[date.month - 1];
  return '$weekday, ${date.day} $month ${date.year}';
}

class DateHeaderRow extends StatelessWidget {
  final int hijriOffsetDays;

  const DateHeaderRow({super.key, required this.hijriOffsetDays});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(
      now.add(Duration(days: hijriOffsetDays)),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatGregorian(now),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text('${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// lib/core/utils/time_format.dart
//
// Clock time is intentionally never localized — always renders fixed
// 12-hour English ("2:30 PM") regardless of the app's active language.
// Bypasses MaterialLocalizations.formatTimeOfDay entirely, since Flutter
// has no flag to force 12-hour (bn's locale default is 24-hour).

import 'package:intl/intl.dart';

import 'package:dhikir_app/l10n/generated/app_localizations.dart';

final _clockFormat = DateFormat('h:mm a', 'en_US');

String formatClockTime(DateTime time) => _clockFormat.format(time);

final _hourMinuteFormat = DateFormat('h:mm', 'en_US');
final _periodFormat = DateFormat('a', 'en_US');

/// "2:45" — for layouts that style the AM/PM part separately.
String formatClockHourMinute(DateTime time) => _hourMinuteFormat.format(time);

/// "AM" / "PM".
String formatClockPeriod(DateTime time) => _periodFormat.format(time);

/// Relative time for "recently viewed" style labels — "Just now",
/// "5 min ago", "2h ago", "3 days ago". Localized, unlike clock times.
String timeAgo(AppLocalizations l10n, DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inMinutes < 1) return l10n.recentJustNow;
  if (diff.inHours < 1) return l10n.recentMinutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l10n.recentHoursAgo(diff.inHours);
  return l10n.recentDaysAgo(diff.inDays);
}

// lib/core/utils/time_format.dart
//
// Clock time is intentionally never localized — always renders fixed
// 12-hour English ("2:30 PM") regardless of the app's active language.
// Bypasses MaterialLocalizations.formatTimeOfDay entirely, since Flutter
// has no flag to force 12-hour (bn's locale default is 24-hour).

import 'package:intl/intl.dart';

final _clockFormat = DateFormat('h:mm a', 'en_US');

String formatClockTime(DateTime time) => _clockFormat.format(time);

final _hourMinuteFormat = DateFormat('h:mm', 'en_US');
final _periodFormat = DateFormat('a', 'en_US');

/// "2:45" — for layouts that style the AM/PM part separately.
String formatClockHourMinute(DateTime time) => _hourMinuteFormat.format(time);

/// "AM" / "PM".
String formatClockPeriod(DateTime time) => _periodFormat.format(time);

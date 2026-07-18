// lib/core/utils/time_format.dart
//
// Clock time is intentionally never localized — always renders fixed
// 12-hour English ("2:30 PM") regardless of the app's active language.
// Bypasses MaterialLocalizations.formatTimeOfDay entirely, since Flutter
// has no flag to force 12-hour (bn's locale default is 24-hour).

import 'package:intl/intl.dart';

final _clockFormat = DateFormat('h:mm a', 'en_US');

String formatClockTime(DateTime time) => _clockFormat.format(time);

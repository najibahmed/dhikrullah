// lib/features/prayer_time/models/forbidden_period.dart
//
// Plain data holder for one of the day's 5 disliked/forbidden prayer
// windows. Not a domain-layer entity — just a named record substitute,
// same spirit as PrayerTimeProvider's `nextPrayer`/`currentPrayer`.

class ForbiddenPeriod {
  final String name;
  final DateTime start;
  final DateTime end;

  const ForbiddenPeriod({
    required this.name,
    required this.start,
    required this.end,
  });

  bool contains(DateTime time) => time.isAfter(start) && time.isBefore(end);
}

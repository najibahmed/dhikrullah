// lib/features/analytics/providers/analytics_provider.dart
//
// Business/data-aggregation state for AnalyticsScreen. Previously this
// logic (and the "combined built-in + custom dhikir list" it depends on)
// was duplicated across four places in analytics_screen.dart
// (_AnalyticsScreenState.initState, _StackedBar, _DailyBreakdownCardState,
// _DayLogRow, _AllTimeTotals) — centralized here so it's computed once
// per screen instance.

import 'package:flutter/foundation.dart';
import 'package:dhikir_app/core/data/dhikir_data.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';

enum AnalyticsPeriod { daily, weekly, monthly }

class DhikirStat {
  final DhikirItem dhikir;
  final int count;
  final int sessions; // days where count > 0

  const DhikirStat({required this.dhikir, required this.count, required this.sessions});
}

class PeriodBar {
  final String label;
  final Map<String, int> countsByDhikir; // id → count
  final int total;

  const PeriodBar({required this.label, required this.countsByDhikir, required this.total});
}

class DayEntry {
  final DateTime date;
  final int total;
  final Map<String, int> byDhikir;
  const DayEntry({required this.date, required this.total, required this.byDhikir});
}

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider() {
    _reload();
  }

  AnalyticsPeriod _period = AnalyticsPeriod.daily;
  AnalyticsPeriod get period => _period;
  set period(AnalyticsPeriod value) {
    if (value == _period) return;
    _period = value;
    notifyListeners();
  }

  late List<DhikirItem> _combined;
  List<DhikirItem> get combined => _combined;

  void _reload() {
    final builtInSession = dhikirList.map((d) => SessionDhikir.fromItem(d)).toList();
    final customSession = CustomDhikirService.getAll().map((d) => SessionDhikir.fromCustom(d)).toList();
    _combined = [...builtInSession, ...customSession];
    notifyListeners();
  }

  (DateTime, DateTime) currentRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case AnalyticsPeriod.daily:
        return (today, today);
      case AnalyticsPeriod.weekly:
        final weekStart = today.subtract(Duration(days: today.weekday % 7));
        return (weekStart, today);
      case AnalyticsPeriod.monthly:
        return (DateTime(now.year, now.month, 1), today);
    }
  }

  List<DhikirStat> buildStats(DateTime from, DateTime to) {
    final stats = <DhikirStat>[];
    for (final item in _combined) {
      final progress = HiveService.getProgress(item.id);
      int total = 0;
      int sessions = 0;
      DateTime d = from;
      while (!d.isAfter(to)) {
        final c = progress.countForDate(d);
        total += c;
        if (c > 0) sessions++;
        d = d.add(const Duration(days: 1));
      }
      stats.add(DhikirStat(dhikir: item, count: total, sessions: sessions));
    }
    stats.sort((a, b) => b.count.compareTo(a.count));
    return stats;
  }

  int grandTotal(List<DhikirStat> stats) => stats.fold(0, (s, e) => s + e.count);

  /// Builds bar chart data for the currently selected period.
  List<PeriodBar> buildBars() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_period) {
      case AnalyticsPeriod.daily:
        // Last 7 days
        return List.generate(7, (i) {
          final d = today.subtract(Duration(days: 6 - i));
          final label = _dayLabel(d);
          final counts = <String, int>{};
          int total = 0;
          for (final item in _combined) {
            final c = HiveService.getProgress(item.id).countForDate(d);
            if (c > 0) counts[item.id] = c;
            total += c;
          }
          return PeriodBar(label: label, countsByDhikir: counts, total: total);
        });

      case AnalyticsPeriod.weekly:
        // Last 8 weeks
        return List.generate(8, (i) {
          final weekStart = today.subtract(Duration(days: today.weekday % 7 + (7 - i) * 7));
          final weekEnd = weekStart.add(const Duration(days: 6));
          final label = 'W${8 - i}';
          final counts = <String, int>{};
          int total = 0;
          for (final item in _combined) {
            final progress = HiveService.getProgress(item.id);
            int c = 0;
            DateTime d = weekStart;
            while (!d.isAfter(weekEnd)) {
              c += progress.countForDate(d);
              d = d.add(const Duration(days: 1));
            }
            if (c > 0) counts[item.id] = c;
            total += c;
          }
          return PeriodBar(label: label, countsByDhikir: counts, total: total);
        });

      case AnalyticsPeriod.monthly:
        // Last 6 months
        return List.generate(6, (i) {
          final offset = 5 - i;
          int m = now.month - offset;
          int y = now.year;
          while (m <= 0) {
            m += 12;
            y--;
          }
          final monthStart = DateTime(y, m, 1);
          final monthEnd = DateTime(y, m + 1, 0);
          final label = _monthShort(m);
          final counts = <String, int>{};
          int total = 0;
          for (final item in _combined) {
            final progress = HiveService.getProgress(item.id);
            int c = 0;
            DateTime d = monthStart;
            while (!d.isAfter(monthEnd)) {
              c += progress.countForDate(d);
              d = d.add(const Duration(days: 1));
            }
            if (c > 0) counts[item.id] = c;
            total += c;
          }
          return PeriodBar(label: label, countsByDhikir: counts, total: total);
        });
    }
  }

  /// Day-by-day log for the weekly (7-day) or monthly (30-day) period.
  List<DayEntry> buildDayEntries(AnalyticsPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entries = <DayEntry>[];

    final int lookback = period == AnalyticsPeriod.weekly ? 7 : 30;
    for (int i = 0; i < lookback; i++) {
      final d = today.subtract(Duration(days: i));
      int total = 0;
      final byDhikir = <String, int>{};
      for (final item in _combined) {
        final c = HiveService.getProgress(item.id).countForDate(d);
        total += c;
        if (c > 0) byDhikir[item.id] = c;
      }
      if (total > 0 || i == 0) {
        entries.add(DayEntry(date: d, total: total, byDhikir: byDhikir));
      }
    }
    return entries;
  }

  List<DhikirStat> buildAllTime() {
    return _combined.map((item) {
      final progress = HiveService.getProgress(item.id);
      final total = progress.dailyCounts.values.fold(0, (sum, c) => sum + c);
      final sessions = progress.dailyCounts.values.where((c) => c > 0).length;
      return DhikirStat(dhikir: item, count: total, sessions: sessions);
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  static String _dayLabel(DateTime d) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month) return 'Today';
    return days[d.weekday % 7];
  }

  static String _monthShort(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m];
  }
}

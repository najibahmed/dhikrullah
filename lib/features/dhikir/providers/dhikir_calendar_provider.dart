// lib/providers/dhikir_calendar_provider.dart
//
// State management for DhikirCalendarScreen.
// Owns the focused month, progress data, and all calendar mutations.
// Exposes pre-computed values so widgets only read, never compute.

import 'package:flutter/material.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';

class DhikirCalendarProvider extends ChangeNotifier {
  final String dhikirId;

  DhikirCalendarProvider(this.dhikirId) {
    // Initialise to the current month and load progress once.
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _progress = HiveService.getProgress(dhikirId);
    _recompute();
  }

  // ── Private state ────────────────────────────────────────────────────────────

  late DateTime _focusedMonth;
  late DhikirProgress _progress;

  // Pre-computed values (updated after every mutation).
  late Set<int> _completedDaysInMonth;
  late int _completedCount;
  late int _currentStreak;
  late int _longestStreak;

  // ── Public reads ─────────────────────────────────────────────────────────────

  DateTime get focusedMonth    => _focusedMonth;
  DhikirProgress get progress  => _progress;
  int get year                 => _focusedMonth.year;
  int get month                => _focusedMonth.month;
  int get daysInMonth          => DateTime(year, month + 1, 0).day;
  int get completedCount       => _completedCount;
  Set<int> get completedDays   => _completedDaysInMonth;
  int get currentStreak        => _currentStreak;
  int get longestStreak        => _longestStreak;
  int get completionPct        => daysInMonth > 0
      ? (_completedCount / daysInMonth * 100).round()
      : 0;

  bool get canGoNext {
    final now = DateTime.now();
    return !(_focusedMonth.year == now.year &&
        _focusedMonth.month == now.month);
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  /// Navigate to the previous month.
  void prevMonth() {
    _focusedMonth = DateTime(year, month - 1);
    _recompute();
    notifyListeners();
  }

  /// Navigate to the next month (no-op if already at current month).
  void nextMonth() {
    if (!canGoNext) return;
    _focusedMonth = DateTime(year, month + 1);
    _recompute();
    notifyListeners();
  }

  /// Jump to a specific year+month (used by the heatmap).
  void jumpTo(int y, int m) {
    _focusedMonth = DateTime(y, m);
    _recompute();
    notifyListeners();
  }

  /// Toggle the completed state for [day] in the focused month.
  /// No-op for future dates.
  Future<void> toggleDay(int day) async {
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) return;
    await HiveService.toggleDate(dhikirId, date);
    _reloadProgress();
  }

  /// Wipe all progress for the focused month.
  Future<void> resetMonth() async {
    await HiveService.resetMonth(dhikirId, year, month);
    _reloadProgress();
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Re-read progress from Hive and refresh computed values.
  void _reloadProgress() {
    _progress = HiveService.getProgress(dhikirId);
    _recompute();
    notifyListeners();
  }

  /// Update all pre-computed fields from current [_progress] + [_focusedMonth].
  /// Call whenever either changes.
  void _recompute() {
    _completedDaysInMonth =
        _progress.completedDaysInMonth(year, month).toSet();
    _completedCount = _completedDaysInMonth.length;
    _currentStreak  = _calcCurrentStreak();
    _longestStreak  = _calcLongestStreak();
  }

  int _calcCurrentStreak() {
    final today = DateTime.now();
    int streak = 0;
    var check = DateTime(today.year, today.month, today.day);
    while (_progress.isDateCompleted(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _calcLongestStreak() {
    if (_progress.completedDates.isEmpty) return 0;
    final sorted = List<String>.from(_progress.completedDates)..sort();
    int longest = 1, current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = DateTime.parse(sorted[i])
          .difference(DateTime.parse(sorted[i - 1]))
          .inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }
}

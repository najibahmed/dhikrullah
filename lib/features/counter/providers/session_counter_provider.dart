// lib/features/counter/providers/session_counter_provider.dart
//
// Business/persistence state for SessionCounterScreen. Animation
// controllers and the PageController stay in the widget's State (they
// need a TickerProvider vsync / drive page-turn animations directly),
// so this provider owns index/goal/per-dhikir completion + all Hive
// reads and writes.

import 'package:flutter/foundation.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';

class SessionCounterProvider extends ChangeNotifier {
  final List<SessionDhikir> dhikirList;
  final DateTime today;

  SessionCounterProvider({
    required this.dhikirList,
    required int initialIndex,
    required int sharedGoal,
  })  : _currentIndex = initialIndex,
        _goal = sharedGoal,
        today = DateTime.now();

  int _currentIndex;
  int get currentIndex => _currentIndex;

  int _goal;
  int get goal => _goal;
  bool get isUnlimited => _goal == -1;

  final Map<String, bool> _sessionCompleted = {};
  bool isCompleted(String id) => _sessionCompleted[id] ?? false;

  SessionDhikir get current => dhikirList[_currentIndex];

  int countFor(String id) => HiveService.getProgress(id).countForDate(today);
  int get todayCount => countFor(current.id);
  bool get isGoalMet => !isUnlimited && todayCount >= _goal;
  double progressFor(int count) => isUnlimited ? (count / 100).clamp(0.0, 1.0) : (count / _goal).clamp(0.0, 1.0);
  double get progress => progressFor(todayCount);

  /// Updates the current page index. Does not animate any PageController —
  /// the widget drives its own PageController and calls this to keep state
  /// in sync (either after a user swipe or after an animated navigation).
  void setIndex(int index) {
    if (index < 0 || index >= dhikirList.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Increments today's count for the current dhikir. Returns true only
  /// when this tap just met the goal (caller plays the completion
  /// animation and schedules auto-advance); false otherwise.
  Future<bool> incrementCurrent() async {
    final id = current.id;
    final count = countFor(id);
    if (!isUnlimited && count >= _goal) return false;

    final effectiveTarget = isUnlimited ? 999999 : _goal;
    final result = await HiveService.incrementCount(id, today, target: effectiveTarget);

    if (!isUnlimited && result >= _goal && !(_sessionCompleted[id] ?? false)) {
      _sessionCompleted[id] = true;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<void> resetCurrent() async {
    final id = current.id;
    await HiveService.resetCount(id, today);
    _sessionCompleted.remove(id);
    notifyListeners();
  }

  void setGoal(int newGoal) {
    if (newGoal == _goal) return;
    _goal = newGoal;
    _sessionCompleted.clear();
    notifyListeners();
  }
}

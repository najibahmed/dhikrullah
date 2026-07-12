// lib/features/dhikir/providers/dhikir_detail_provider.dart
//
// Business/persistence state for DhikirDetailScreen. Deliberately excludes
// animation controllers: AnimationController needs a TickerProvider (vsync),
// which a plain ChangeNotifier can't supply, so pulse/completion animation
// stays owned by the screen's State and is triggered from the return value
// of incrementCounter().

import 'package:flutter/material.dart';
import 'package:dhikir_app/core/data/dhikir_data.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';

class DhikirDetailProvider extends ChangeNotifier {
  final DhikirItem dhikir;
  final DateTime today;

  static const List<int> goalOptions = [33, 34, 99, 100, -1];

  DhikirDetailProvider(this.dhikir) : today = DateTime.now() {
    _progress = HiveService.getProgress(dhikir.id);
  }

  late DhikirProgress _progress;
  DhikirProgress get progress => _progress;

  int _target = 100;
  int get target => _target;
  bool get isUnlimited => _target == -1;

  bool _justCompleted = false;
  bool get justCompleted => _justCompleted;

  int get todayCount => _progress.countForDate(today);
  bool get isGoalMet => !isUnlimited && todayCount >= _target;
  double get progressRatio =>
      isUnlimited ? ((todayCount % 100) / 100).clamp(0.0, 1.0) : (todayCount / _target).clamp(0.0, 1.0);

  bool get isFavourite {
    final builtInFavIds = HiveService.builtInFavoriteIds.toSet();
    final myFavoritesIds = CustomDhikirService.getFavorites().map((d) => d.id).toList();
    return [...builtInFavIds, ...myFavoritesIds].contains(dhikir.id);
  }

  void _reload() {
    _progress = HiveService.getProgress(dhikir.id);
    notifyListeners();
  }

  /// Increments today's count. Returns true only when this tap just met the
  /// goal (caller plays the completion animation); false otherwise,
  /// including when the goal was already met (caller just plays the pulse).
  Future<bool> incrementCounter() async {
    final count = _progress.countForDate(today);
    if (!isUnlimited && count >= _target) return false;

    final effectiveTarget = isUnlimited ? 100 : _target;
    final result = await HiveService.incrementCount(dhikir.id, today, target: effectiveTarget);
    _reload();

    if (!isUnlimited && result >= _target && !_justCompleted) {
      _justCompleted = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> resetCounter() async {
    await HiveService.resetCount(dhikir.id, today);
    _justCompleted = false;
    _reload();
  }

  void setTarget(int newTarget) {
    if (newTarget == _target) return;
    _target = newTarget;
    _justCompleted = false;
    notifyListeners();
  }

  Future<void> toggleDay(int day) async {
    final date = DateTime(today.year, today.month, day);
    await HiveService.toggleDate(dhikir.id, date);
    _reload();
  }

  Future<void> resetMonth() async {
    await HiveService.resetMonth(dhikir.id, today.year, today.month);
    _justCompleted = false;
    _reload();
  }

  Future<void> toggleFavourite() async {
    final isBuiltIn = dhikirList.any((d) => d.id == dhikir.id);
    if (isBuiltIn) {
      await HiveService.toggleBuiltInFavorite(dhikir.id);
    } else {
      await CustomDhikirService.toggleFavorite(dhikir.id);
    }
    notifyListeners();
  }
}

// lib/services/hive_service.dart
//
// Central Hive access layer.
// Responsible for:
//  • DhikirProgress  (counter + calendar data, keyed by dhikirId)
//  • Favourites      (a simple bool box keyed by dhikirId)
//
// Both built-in and custom dhikir share the same boxes — they differ
// only in which service creates / deletes the metadata record.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/models/custom_dhikir_model.dart';

class HiveService {
  // ── Box names ───────────────────────────────────────────────────────────────
  static const String _progressBox = 'dhikir_progress_v2';
  static const String _favoritesBox = 'dhikir_favorites_v1';

  static late Box<DhikirProgress> _progress;
  static late Box<bool> _favorites; // key=dhikirId, value=true when favourite

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Must be called once in main() before runApp.
  /// Registers all Hive adapters and opens both boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DhikirProgressAdapter());
    Hive.registerAdapter(CustomDhikirItemAdapter());
    _progress = await Hive.openBox<DhikirProgress>(_progressBox);
    _favorites = await Hive.openBox<bool>(_favoritesBox);
  }

  // ── Progress (counter + calendar) ───────────────────────────────────────────

  /// Returns the [DhikirProgress] for [dhikirId], creating one if absent.
  static DhikirProgress getProgress(String dhikirId) {
    if (!_progress.containsKey(dhikirId)) {
      final entry = DhikirProgress.create(dhikirId);
      _progress.put(dhikirId, entry);
      return entry;
    }
    return _progress.get(dhikirId)!;
  }

  /// Toggle the completed-date marker for [date].
  static Future<void> toggleDate(String dhikirId, DateTime date) async {
    final p = getProgress(dhikirId);
    final key = DhikirProgress.dateKey(date);
    if (p.completedDates.contains(key)) {
      p.completedDates.remove(key);
    } else {
      p.completedDates.add(key);
    }
    await p.save();
  }

  /// Increment today's tap count. Auto-completes the day at [target].
  /// Returns the new count.
  static Future<int> incrementCount(
    String dhikirId,
    DateTime date, {
    int target = 100,
  }) async {
    final p = getProgress(dhikirId);
    final key = DhikirProgress.dateKey(date);
    final newCount = (p.dailyCounts[key] ?? 0) + 1;
    p.dailyCounts[key] = newCount;

    if (newCount >= target && !p.completedDates.contains(key)) {
      p.completedDates.add(key);
    }
    await p.save();
    return newCount;
  }

  /// Reset tap counter for [date] without un-checking the calendar day.
  static Future<void> resetCount(String dhikirId, DateTime date) async {
    final p = getProgress(dhikirId);
    p.dailyCounts.remove(DhikirProgress.dateKey(date));
    await p.save();
  }

  /// Wipe all progress for a single month.
  static Future<void> resetMonth(String dhikirId, int year, int month) async {
    final p = getProgress(dhikirId);
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    p.completedDates.removeWhere((d) => d.startsWith(prefix));
    p.dailyCounts.removeWhere((k, _) => k.startsWith(prefix));
    await p.save();
  }

  /// Erase all progress for [dhikirId].
  static Future<void> resetAll(String dhikirId) async {
    final p = getProgress(dhikirId);
    p.completedDates.clear();
    p.dailyCounts.clear();
    await p.save();
  }

  /// All dhikirIds that have a progress record (used by analytics).
  static List<String> get allTrackedIds => _progress.keys.cast<String>().toList();

  // ── Favourites ───────────────────────────────────────────────────────────────
  // Unified store — works for both built-in and custom dhikir IDs.

  /// True when [dhikirId] is marked favourite.
  static bool isFavorite(String dhikirId) => _favorites.get(dhikirId) ?? false;

  /// Persist [value] as the favourite state for [dhikirId].
  static Future<void> setFavorite(String dhikirId, bool value) async {
    if (value) {
      await _favorites.put(dhikirId, true);
    } else {
      await _favorites.delete(dhikirId);
    }
  }

  /// Toggle favourite state for [dhikirId].
  static Future<void> toggleFavorite(String dhikirId) => setFavorite(dhikirId, !isFavorite(dhikirId));

  /// Alias kept for compatibility with FavouriteScreen built-in rows.
  static Future<void> toggleBuiltInFavorite(String dhikirId) => toggleFavorite(dhikirId);

  /// All currently-favourited dhikir IDs (built-in + custom combined).
  static List<String> get allFavoriteIds => _favorites.keys.cast<String>().toList();

  /// Alias used by FavouriteScreen to read built-in favourite IDs.
  static List<String> get builtInFavoriteIds => allFavoriteIds;
}

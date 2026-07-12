// lib/providers/favorites_provider.dart
//
// Single source of truth for which dhikir IDs are marked as favourite.
// Both built-in and custom dhikir share the same Hive-backed store,
// so any screen can call [isFavorite] / [toggle] without touching
// service classes directly.

import 'package:flutter/material.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';

class FavoritesProvider extends ChangeNotifier {
  // Internal cache for quick O(1) lookup.
  late Set<String> _favoriteIds;

  FavoritesProvider() {
    _favoriteIds = HiveService.builtInFavoriteIds.toSet();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns true when [id] is in the favourites set.
  bool isFavorite(String id) => _favoriteIds.contains(id);

  /// Toggle favourite state for [id] (built-in or custom).
  /// Persists via [HiveService] and notifies all listeners.
  Future<void> toggle(String id) async {
    await HiveService.toggleBuiltInFavorite(id);

    // Keep local cache in sync without a full re-read.
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }

    // Also sync the isFavorite field on the CustomDhikirItem if applicable.
    final custom = CustomDhikirService.getById(id);
    if (custom != null) {
      custom.isFavorite = _favoriteIds.contains(id);
      await CustomDhikirService.update(custom);
    }

    notifyListeners();
  }

  /// Full list of favourite IDs (read-only view).
  Set<String> get all => Set.unmodifiable(_favoriteIds);

  /// Call after deleting a custom dhikir to purge its favourite entry.
  Future<void> remove(String id) async {
    if (!_favoriteIds.contains(id)) return;
    await HiveService.setFavorite(id, false);
    _favoriteIds.remove(id);
    notifyListeners();
  }

  /// Reload from storage (e.g. after hot-restart or external mutation).
  void refresh() {
    _favoriteIds = HiveService.allFavoriteIds.toSet();
    notifyListeners();
  }
}

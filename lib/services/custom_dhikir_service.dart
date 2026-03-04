// lib/services/custom_dhikir_service.dart
//
// CRUD operations for user-created (custom) dhikir.
// Progress tracking (counter + calendar) is handled by HiveService,
// so this service only manages the metadata box.
// Favourite state is also delegated to HiveService so built-in and
// custom dhikir share a single unified favourites store.

import 'package:hive_flutter/hive_flutter.dart';
import '../models/custom_dhikir_model.dart';
import 'hive_service.dart';

class CustomDhikirService {
  static const String _boxName = 'custom_dhikir_v1';
  static late Box<CustomDhikirItem> _box;

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Open the custom-dhikir box.
  /// HiveService.init() must run first (it registers the adapter).
  static Future<void> init() async {
    _box = await Hive.openBox<CustomDhikirItem>(_boxName);
  }

  // ── Read ────────────────────────────────────────────────────────────────────

  /// All custom dhikir, newest first.
  static List<CustomDhikirItem> getAll() => _box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Only custom dhikir that are currently marked favourite.
  static List<CustomDhikirItem> getFavorites() =>
      _box.values.where((d) => HiveService.isFavorite(d.id)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Lookup by id; returns null when not found.
  static CustomDhikirItem? getById(String id) => _box.get(id);

  /// Total count of custom dhikir.
  static int get count => _box.length;

  // ── Write ───────────────────────────────────────────────────────────────────

  /// Persist a new [item].
  static Future<void> add(CustomDhikirItem item) =>
      _box.put(item.id, item);

  /// Save changes to an existing [item].
  static Future<void> update(CustomDhikirItem item) => item.save();

  /// Delete [id] and clean up its favourite flag.
  static Future<void> delete(String id) async {
    await _box.delete(id);
    await HiveService.setFavorite(id, false);
  }

  /// Toggle favourite via the shared HiveService store.
  static Future<void> toggleFavorite(String id) =>
      HiveService.toggleFavorite(id);
}

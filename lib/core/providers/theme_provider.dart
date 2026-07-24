// lib/providers/theme_provider.dart
//
// Manages app-wide theme (light / dark / system) and persists
// the user's choice with shared_preferences.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist the theme mode index in SharedPreferences.
const _kThemeModeKey = 'theme_mode';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeProvider(this._themeMode);

  // ── Public getters ──────────────────────────────────────────────────────────

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  // ── Factory: load persisted value before first paint ───────────────────────

  /// Call this in main() before runApp to restore the saved theme.
  static Future<ThemeProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_kThemeModeKey) ?? ThemeMode.system.index;
    return ThemeProvider(ThemeMode.values[index]);
  }

  // ── Mutators ────────────────────────────────────────────────────────────────

  /// Persist and apply a new [ThemeMode].
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, mode.index);
  }
}

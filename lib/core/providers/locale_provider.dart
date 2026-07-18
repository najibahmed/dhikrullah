// lib/core/providers/locale_provider.dart
//
// Manages the app's UI language and persists the user's choice with
// shared_preferences. Mirrors ThemeProvider's load()-before-runApp pattern.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist the selected locale's language code in SharedPreferences.
const _kLocaleKey = 'locale_language_code';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  LocaleProvider(this._locale);

  /// The selected locale, or null to follow the system locale.
  Locale? get locale => _locale;

  /// Call this in main() before runApp to restore the saved locale.
  static Future<LocaleProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    return LocaleProvider(code == null ? null : Locale(code));
  }

  /// Persist and apply a new locale. Pass null to follow the system locale.
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}

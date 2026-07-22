// lib/core/providers/font_size_provider.dart
//
// Screen-scoped font-size settings for Arabic/transliteration/meaning text.
// Each screen constructs its own FontSizeProvider with its own FontSizeConfig
// (defaults/ranges tailored to that screen's design) and its own persisted
// SharedPreferences key-prefix, rather than sharing one app-wide instance —
// per CLAUDE.md, screen-scoped state is locally constructed, not hoisted
// into the global provider tree.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeConfig {
  final String id;
  final double arabicDefault;
  final double arabicMin;
  final double arabicMax;
  final double transliterationDefault;
  final double transliterationMin;
  final double transliterationMax;
  final double meaningDefault;
  final double meaningMin;
  final double meaningMax;

  const FontSizeConfig({
    required this.id,
    required this.arabicDefault,
    required this.arabicMin,
    required this.arabicMax,
    required this.transliterationDefault,
    required this.transliterationMin,
    required this.transliterationMax,
    required this.meaningDefault,
    required this.meaningMin,
    required this.meaningMax,
  });
}

class FontSizeProvider extends ChangeNotifier {
  final FontSizeConfig config;

  late double _arabicFontSize = config.arabicDefault;
  late double _transliterationFontSize = config.transliterationDefault;
  late double _meaningFontSize = config.meaningDefault;

  FontSizeProvider(this.config);

  double get arabicFontSize => _arabicFontSize;
  double get transliterationFontSize => _transliterationFontSize;
  double get meaningFontSize => _meaningFontSize;

  String get _arabicKey => '${config.id}_font_size_arabic';
  String get _transliterationKey => '${config.id}_font_size_transliteration';
  String get _meaningKey => '${config.id}_font_size_meaning';

  /// Loads any persisted sizes for this screen and applies them. Not
  /// awaited by callers — fire-and-forget, notifies once loaded.
  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble(_arabicKey) ?? config.arabicDefault;
    _transliterationFontSize =
        prefs.getDouble(_transliterationKey) ?? config.transliterationDefault;
    _meaningFontSize = prefs.getDouble(_meaningKey) ?? config.meaningDefault;
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    if (_arabicFontSize == size) return;
    _arabicFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_arabicKey, size);
  }

  Future<void> setTransliterationFontSize(double size) async {
    if (_transliterationFontSize == size) return;
    _transliterationFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_transliterationKey, size);
  }

  Future<void> setMeaningFontSize(double size) async {
    if (_meaningFontSize == size) return;
    _meaningFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_meaningKey, size);
  }
}

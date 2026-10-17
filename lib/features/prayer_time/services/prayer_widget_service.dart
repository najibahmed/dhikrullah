// lib/features/prayer_time/services/prayer_widget_service.dart
//
// Feeds the Android home-screen prayer widget. Prayer times are computed
// here (via PrayerTimeProvider) and persisted as JSON; the native
// PrayerWidgetProvider only reads them — it never calculates prayer times,
// same contract as the alarm module (alarm_api_contract.md).

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/features/prayer_time/services/prayer_widget_channel.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

/// Read natively as `flutter.prayer_widget_data` in FlutterSharedPreferences.
const _kWidgetDataKey = 'prayer_widget_data';

/// Days of times persisted, so the widget keeps rolling over without the
/// app being opened.
const _kDays = 7;

class PrayerWidgetService {
  PrayerWidgetService._();

  /// Persist yesterday plus the next [_kDays] days of Fajr…Isha windows with names in
  /// [locale], then ask placed widgets to re-render. Never throws — having
  /// no widget (or no native side) is not an error.
  static Future<void> sync(PrayerTimeProvider provider, Locale locale) async {
    try {
      final l10n = lookupAppLocalizations(locale);
      final days = <Map<String, Object>>[];
      if (provider.coordinates != null) {
        final now = DateTime.now();
        // Starts at yesterday so an Isha window still running past
        // midnight (it ends at the middle of the night) stays highlighted.
        for (var i = -1; i < _kDays; i++) {
          final date = DateTime(now.year, now.month, now.day + i);
          // Same windows the app's Prayer Time screen uses (Fajr ends at
          // sunrise, Isha at mid-night, …), so the widget's "current
          // prayer" always matches the app.
          final windows = provider.windowsForDate(date);
          final ordered = [
            for (final label in prayerLabels) windows.where((w) => w.name == label).firstOrNull,
          ];
          if (ordered.any((w) => w == null)) continue;
          days.add({
            'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            'starts': [for (final w in ordered) w!.start.millisecondsSinceEpoch],
            'ends': [for (final w in ordered) w!.end.millisecondsSinceEpoch],
          });
        }
      }
      final data = {
        'v': 2,
        'names': [l10n.prayerNameFajr, l10n.prayerNameDhuhr, l10n.prayerNameAsr, l10n.prayerNameMaghrib, l10n.prayerNameIsha],
        'days': days,
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kWidgetDataKey, jsonEncode(data));
      await PrayerWidgetChannel.refresh();
    } catch (e) {
      debugPrint('PrayerWidgetService.sync failed: $e');
    }
  }

  /// Whether this launcher can pin the widget from inside the app.
  static Future<bool> canPin() async {
    try {
      return await PrayerWidgetChannel.isPinSupported();
    } catch (_) {
      return false;
    }
  }

  /// "Add widget to Home screen" action: refresh the data first so the new
  /// widget appears populated, then ask the launcher to show its pin
  /// dialog. Falls back to manual instructions when pinning isn't possible.
  static Future<void> addToHomeScreen(BuildContext context) async {
    final provider = context.read<PrayerTimeProvider>();
    final locale = Localizations.localeOf(context);
    final messenger = ScaffoldMessenger.of(context);
    final unsupported = context.l10n.prayerWidgetPinUnsupported;
    await sync(provider, locale);
    var pinned = false;
    try {
      pinned = await PrayerWidgetChannel.requestPin();
    } catch (_) {}
    if (!pinned) {
      messenger.showSnackBar(SnackBar(content: Text(unsupported)));
    }
  }
}

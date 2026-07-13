// lib/features/prayer_time/providers/prayer_time_provider.dart
//
// Holds today's prayer times (computed locally via adhan_dart from the
// device's GPS coordinates), the Hijri date offset, and per-prayer
// notification toggles. Constructed synchronously in main.dart's
// MultiProvider (like FavoritesProvider) — call init() once the widget
// tree is up so a location-permission prompt never blocks first paint.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dhikir_app/features/prayer_time/services/location_service.dart';
import 'package:dhikir_app/features/prayer_time/services/prayer_notification_service.dart';

const _kHijriOffsetKey = 'prayer_hijri_offset_days';
const _kNotifyPrefixKey = 'prayer_notify_';
const _kMadhabKey = 'prayer_madhab';

const prayerLabels = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

class PrayerTimeProvider extends ChangeNotifier {
  bool _initialized = false;
  bool locationGranted = false;
  Coordinates? coordinates;

  int hijriOffsetDays = 0;
  Madhab madhab = Madhab.hanafi;
  final Map<String, bool> prayerNotificationsEnabled = {
    for (final label in prayerLabels) label: true,
  };

  PrayerTimes? _today;
  DateTime? _cachedForDate;

  // ── Init ─────────────────────────────────────────────────────────────────

  /// Idempotent — safe to call from multiple screens/initStates.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadSettings();

    // Show a cached location immediately if we have one, then refresh.
    final cached = await LocationService.getCachedCoordinates();
    if (cached != null) {
      coordinates = cached;
      locationGranted = true;
      _recompute();
      notifyListeners();
    }

    final granted = await LocationService.checkAndRequestPermission();
    locationGranted = granted;
    if (!granted) {
      notifyListeners();
      return;
    }

    coordinates = await LocationService.getCurrentCoordinates();
    _recompute();
    notifyListeners();

    await PrayerNotificationService.init();
    await _rescheduleNotifications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    hijriOffsetDays = prefs.getInt(_kHijriOffsetKey) ?? 0;
    madhab = prefs.getString(_kMadhabKey) == 'shafi' ? Madhab.shafi : Madhab.hanafi;
    for (final label in prayerLabels) {
      prayerNotificationsEnabled[label] =
          prefs.getBool('$_kNotifyPrefixKey$label') ?? true;
    }
  }

  // ── Derived state ────────────────────────────────────────────────────────

  /// Today's prayer times, recomputed automatically if the calendar day
  /// has rolled over since the last computation (handles midnight without
  /// a background timer).
  PrayerTimes? get today {
    final now = DateTime.now();
    final isStale = _cachedForDate == null ||
        _cachedForDate!.year != now.year ||
        _cachedForDate!.month != now.month ||
        _cachedForDate!.day != now.day;
    if (isStale && coordinates != null) _recompute();
    return _today;
  }

  PrayerTimes? _prayerTimesFor(DateTime date) {
    if (coordinates == null) return null;
    final params = CalculationMethodParameters.muslimWorldLeague()
      ..madhab = madhab;
    return PrayerTimes(
      date: date,
      coordinates: coordinates!,
      calculationParameters: params,
    );
  }

  void _recompute() {
    final now = DateTime.now();
    _today = _prayerTimesFor(now);
    _cachedForDate = now;
  }

  /// Next upcoming prayer name + local DateTime, or null if location
  /// hasn't been resolved yet.
  ({String name, DateTime time})? get nextPrayer {
    final times = today;
    if (times == null) return null;
    final prayer = times.nextPrayer();
    return (name: prayer.displayName, time: times.timeForPrayer(prayer).toLocal());
  }

  /// The prayer period we're currently inside — name, its start/end time,
  /// and how far through it we are (0.0-1.0). `start`/`end` are always
  /// consecutive prayer boundaries (adhan_dart's currentPrayer()/
  /// nextPrayer() pairing), including the pre-Fajr (ishaBefore -> fajr)
  /// and post-Isha (isha -> fajrAfter) wraparound cases.
  ({String name, DateTime start, DateTime end, double progress})? get currentPrayer {
    final times = today;
    if (times == null) return null;
    final current = times.currentPrayer();
    final next = times.nextPrayer();
    final start = times.timeForPrayer(current).toLocal();
    final end = times.timeForPrayer(next).toLocal();
    final totalSeconds = end.difference(start).inSeconds;
    final elapsedSeconds = DateTime.now().difference(start).inSeconds;
    final progress =
        totalSeconds > 0 ? (elapsedSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;
    return (name: current.displayName, start: start, end: end, progress: progress);
  }

  /// Time remaining until the current prayer period ends, or null if
  /// location hasn't been resolved yet.
  Duration? get currentPrayerRemaining {
    final current = currentPrayer;
    if (current == null) return null;
    return current.end.difference(DateTime.now());
  }

  // ── Mutators ─────────────────────────────────────────────────────────────

  Future<void> setHijriOffset(int offset) async {
    hijriOffsetDays = offset.clamp(-1, 1);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHijriOffsetKey, hijriOffsetDays);
  }

  Future<void> setMadhab(Madhab value) async {
    madhab = value;
    _recompute();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMadhabKey, value == Madhab.shafi ? 'shafi' : 'hanafi');
    await _rescheduleNotifications();
  }

  Future<void> setPrayerNotification(String label, bool enabled) async {
    prayerNotificationsEnabled[label] = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kNotifyPrefixKey$label', enabled);
    await _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    final todayTimes = today;
    final tomorrowTimes = _prayerTimesFor(DateTime.now().add(const Duration(days: 1)));
    if (todayTimes == null || tomorrowTimes == null) return;
    await PrayerNotificationService.scheduleForDay(
      today: todayTimes,
      tomorrow: tomorrowTimes,
      enabled: prayerNotificationsEnabled,
    );
  }
}

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

import 'package:dhikir_app/features/prayer_time/models/forbidden_period.dart';
import 'package:dhikir_app/features/prayer_time/services/location_service.dart';
import 'package:dhikir_app/features/prayer_time/services/prayer_notification_service.dart';

const _kHijriOffsetKey = 'prayer_hijri_offset_days';
const _kNotifyPrefixKey = 'prayer_notify_';
const _kMadhabKey = 'prayer_madhab';

const prayerLabels = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// Nafl prayer times with their own opt-in notification toggle, kept
/// separate from [prayerLabels] since they aren't `Prayer` enum values
/// and default to off (unlike the 5 obligatory prayers).
const optionalNotificationLabels = ['Tahajjud', 'Ishraq', 'Chasht'];

/// Coarse status derived from the provider's existing fields — purely
/// computed, not a separate persisted state machine.
enum PrayerStatus {
  loading,
  permissionRequired,
  gpsDisabled,
  locationUnavailable,
  error,
  forbidden,
  normal,
}

class PrayerTimeProvider extends ChangeNotifier {
  bool _initialized = false;
  bool _loading = true;
  bool locationGranted = false;
  bool gpsServiceEnabled = true;
  bool locationError = false;
  Coordinates? coordinates;

  int hijriOffsetDays = 0;
  Madhab madhab = Madhab.hanafi;
  final Map<String, bool> prayerNotificationsEnabled = {
    for (final label in prayerLabels) label: true,
    for (final label in optionalNotificationLabels) label: false,
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
      _loading = false;
      notifyListeners();
    }

    gpsServiceEnabled = await LocationService.isServiceEnabled();
    final granted = await LocationService.checkAndRequestPermission();
    locationGranted = granted;
    if (!granted) {
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      coordinates = await LocationService.getCurrentCoordinates();
      locationError = false;
    } catch (_) {
      locationError = true;
    }
    _recompute();
    _loading = false;
    notifyListeners();

    await PrayerNotificationService.init();
    await _rescheduleNotifications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    hijriOffsetDays = prefs.getInt(_kHijriOffsetKey) ?? 0;
    madhab =
        prefs.getString(_kMadhabKey) == 'shafi' ? Madhab.shafi : Madhab.hanafi;
    for (final label in prayerLabels) {
      prayerNotificationsEnabled[label] =
          prefs.getBool('$_kNotifyPrefixKey$label') ?? true;
    }
    for (final label in optionalNotificationLabels) {
      prayerNotificationsEnabled[label] =
          prefs.getBool('$_kNotifyPrefixKey$label') ?? false;
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

  /// Builds the unified Tahajjud/Fajr/Ishraq/Chasht/Dhuhr/Asr/Maghrib/Isha
  /// cycle for [times]'s calendar date. [yesterday] (if available) supplies
  /// the leading Tahajjud window (last night's middle-of-night -> this
  /// Fajr); the trailing Tahajjud window (tonight's middle-of-night ->
  /// tomorrow's Fajr) is always derived from [times] itself. Fajr's window
  /// runs through to Ishraq's start (sunrise + 15min, matching the
  /// existing Sunrise-forbidden window's end) rather than stopping at
  /// sunrise, so there's never a "no current prayer" gap during that
  /// forbidden window.
  List<({String name, DateTime start, DateTime end})> _buildWindows(
      PrayerTimes times, PrayerTimes? yesterday) {
    final sunrise = times.sunrise.toLocal();
    final dhuhr = times.dhuhr.toLocal();
    final ishraqStart = sunrise.add(const Duration(minutes: 15));
    final chashtStart = sunrise.add(Duration(
        microseconds: dhuhr.difference(sunrise).inMicroseconds ~/ 2));
    final tonightMiddle = SunnahTimes(times).middleOfTheNight.toLocal();

    return [
      if (yesterday != null)
        (
          name: 'Tahajjud',
          start: SunnahTimes(yesterday).middleOfTheNight.toLocal(),
          end: times.fajr.toLocal(),
        ),
      (name: 'Fajr', start: times.fajr.toLocal(), end: ishraqStart),
      (name: 'Ishraq', start: ishraqStart, end: chashtStart),
      (name: 'Chasht', start: chashtStart, end: dhuhr),
      (name: 'Dhuhr', start: dhuhr, end: times.asr.toLocal()),
      (
        name: 'Asr',
        start: times.asr.toLocal(),
        end: times.maghrib.toLocal()
      ),
      (
        name: 'Maghrib',
        start: times.maghrib.toLocal(),
        end: times.isha.toLocal()
      ),
      (name: 'Isha', start: times.isha.toLocal(), end: tonightMiddle),
      (name: 'Tahajjud', start: tonightMiddle, end: times.fajrAfter.toLocal()),
    ];
  }

  List<({String name, DateTime start, DateTime end})> get _prayerWindows {
    final times = today;
    if (times == null) return const [];
    final yesterday =
        _prayerTimesFor(DateTime.now().subtract(const Duration(days: 1)));
    return _buildWindows(times, yesterday);
  }

  /// Today's prayer windows for display — Tahajjud appears once (this
  /// morning's instance), with no trailing tonight's-Tahajjud duplicate.
  /// Used by the detail screen's prayer list.
  List<({String name, DateTime start, DateTime end})>
      get displayPrayerWindows {
    final windows = _prayerWindows;
    if (windows.isEmpty) return windows;
    return windows.sublist(0, windows.length - 1);
  }

  /// Next upcoming prayer name + local DateTime, or null if location
  /// hasn't been resolved yet.
  ({String name, DateTime time})? get nextPrayer {
    final period = nextPrayerPeriod;
    if (period == null) return null;
    return (name: period.name, time: period.start);
  }

  /// The prayer period we're currently inside — name, its start/end time,
  /// and how far through it we are (0.0-1.0).
  ({String name, DateTime start, DateTime end, double progress})?
      get currentPrayer {
    final windows = _prayerWindows;
    final now = DateTime.now();
    for (final w in windows) {
      if (!now.isBefore(w.start) && now.isBefore(w.end)) {
        final totalSeconds = w.end.difference(w.start).inSeconds;
        final elapsedSeconds = now.difference(w.start).inSeconds;
        final progress = totalSeconds > 0
            ? (elapsedSeconds / totalSeconds).clamp(0.0, 1.0)
            : 0.0;
        return (name: w.name, start: w.start, end: w.end, progress: progress);
      }
    }
    return null;
  }

  /// Time remaining until the current prayer period ends, or null if
  /// location hasn't been resolved yet.
  Duration? get currentPrayerRemaining {
    final current = currentPrayer;
    if (current == null) return null;
    return current.end.difference(DateTime.now());
  }

  /// The day's 5 disliked/forbidden prayer windows, or an empty list if
  /// location hasn't been resolved yet.
  List<ForbiddenPeriod> get forbiddenPeriods {
    final times = today;
    if (times == null) return const [];
    return [
      ForbiddenPeriod(
        name: 'Sunrise',
        start: times.sunrise.toLocal(),
        end: times.sunrise.toLocal().add(const Duration(minutes: 15)),
      ),
      ForbiddenPeriod(
        name: 'Zawal',
        start: times.dhuhr.toLocal().subtract(const Duration(minutes: 10)),
        end: times.dhuhr.toLocal(),
      ),
      ForbiddenPeriod(
        name: 'Sunset',
        start: times.sunset.toLocal().subtract(const Duration(minutes: 15)),
        end: times.sunset.toLocal(),
      ),
    ];
  }

  /// The forbidden period we're currently inside, or null if now falls
  /// outside all of them.
  ForbiddenPeriod? get activeForbiddenPeriod {
    final now = DateTime.now();
    for (final period in forbiddenPeriods) {
      if (period.contains(now)) return period;
    }
    return null;
  }

  bool get isForbiddenTime => activeForbiddenPeriod != null;

  /// Tonight's (or this morning's, if we're in the post-midnight tail)
  /// Tahajjud window, or null if location isn't resolved yet.
  ({DateTime start, DateTime end})? get tahajjudPeriod {
    for (final w in _prayerWindows) {
      if (w.name == 'Tahajjud') return (start: w.start, end: w.end);
    }
    return null;
  }

  /// Next prayer's own start/end window and time remaining until it
  /// starts, or null if location hasn't been resolved yet.
  ({String name, DateTime start, DateTime end, Duration startsIn})?
      get nextPrayerPeriod {
    final windows = _prayerWindows;
    final now = DateTime.now();
    for (var i = 0; i < windows.length; i++) {
      if (!now.isBefore(windows[i].start) && now.isBefore(windows[i].end)) {
        if (i + 1 >= windows.length) return null;
        final next = windows[i + 1];
        return (
          name: next.name,
          start: next.start,
          end: next.end,
          startsIn: next.start.difference(now),
        );
      }
    }
    return null;
  }

  /// Today's Sehri-end (Fajr) / Iftar (Maghrib) with a countdown that
  /// flips to tomorrow's schedule once today's Iftar has passed, or null
  /// if location hasn't been resolved yet.
  ({
    String title,
    DateTime sehriEnd,
    DateTime iftar,
    String countdownLabel,
    Duration countdown
  })? get sehriIftarInfo {
    final times = today;
    if (times == null) return null;
    final now = DateTime.now();
    final iftarToday = times.maghrib.toLocal();
    if (now.isBefore(iftarToday)) {
      return (
        title: "Today's Schedule",
        sehriEnd: times.fajr.toLocal(),
        iftar: iftarToday,
        countdownLabel: 'Iftar starts in',
        countdown: iftarToday.difference(now),
      );
    }
    final tomorrow = _prayerTimesFor(now.add(const Duration(days: 1)));
    if (tomorrow == null) return null;
    final sehriEndTomorrow = times.fajrAfter.toLocal();
    return (
      title: "Tomorrow's Schedule",
      sehriEnd: sehriEndTomorrow,
      iftar: tomorrow.maghrib.toLocal(),
      countdownLabel: 'Sehri ends in',
      countdown: sehriEndTomorrow.difference(now),
    );
  }

  bool get isTahajjudTime => currentPrayer?.name == 'Tahajjud';

  /// Coarse UI status, purely derived from the fields above.
  PrayerStatus get status {
    if (_loading) return PrayerStatus.loading;
    if (!gpsServiceEnabled) return PrayerStatus.gpsDisabled;
    if (!locationGranted) return PrayerStatus.permissionRequired;
    if (coordinates == null) {
      return locationError
          ? PrayerStatus.locationUnavailable
          : PrayerStatus.loading;
    }
    if (today == null) return PrayerStatus.error;
    if (isForbiddenTime) return PrayerStatus.forbidden;
    return PrayerStatus.normal;
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
    await prefs.setString(
        _kMadhabKey, value == Madhab.shafi ? 'shafi' : 'hanafi');
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
    final tomorrowTimes =
        _prayerTimesFor(DateTime.now().add(const Duration(days: 1)));
    if (todayTimes == null || tomorrowTimes == null) return;
    final todayWindows = _buildWindows(todayTimes,
        _prayerTimesFor(DateTime.now().subtract(const Duration(days: 1))));
    final tomorrowWindows = _buildWindows(tomorrowTimes, todayTimes);
    DateTime? find(
        List<({String name, DateTime start, DateTime end})> ws, String name) {
      for (final w in ws) {
        if (w.name == name) return w.start;
      }
      return null;
    }

    await PrayerNotificationService.scheduleForDay(
      today: todayTimes,
      tomorrow: tomorrowTimes,
      enabled: prayerNotificationsEnabled,
      tahajjudToday: find(todayWindows, 'Tahajjud'),
      tahajjudTomorrow: find(tomorrowWindows, 'Tahajjud'),
      ishraqToday: find(todayWindows, 'Ishraq'),
      ishraqTomorrow: find(tomorrowWindows, 'Ishraq'),
      chashtToday: find(todayWindows, 'Chasht'),
      chashtTomorrow: find(tomorrowWindows, 'Chasht'),
    );
  }
}

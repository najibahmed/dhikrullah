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
const _kSoundPrefixKey = 'prayer_sound_';
const _kMadhabKey = 'prayer_madhab';
const _kHijriDayStartKey = 'prayer_hijri_day_start';

/// Max number of non-today dates kept in [PrayerTimeProvider._dateCache],
/// evicted oldest-first once exceeded — bounds memory while keeping
/// prev/next navigation around the selected date instant.
const _kMaxDateCacheEntries = 14;

/// When the Hijri calendar day is considered to roll over.
enum HijriDayStart { midnight, sunset }

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
  bool permissionPermanentlyDenied = false;
  Coordinates? coordinates;

  int hijriOffsetDays = 0;
  HijriDayStart hijriDayStart = HijriDayStart.midnight;
  Madhab madhab = Madhab.hanafi;
  final Map<String, bool> prayerNotificationsEnabled = {
    for (final label in prayerLabels) label: false,
    for (final label in optionalNotificationLabels) label: false,
  };

  /// Per-prayer notification sound choice: `'default'` or `'silent'`.
  final Map<String, String> prayerSoundChoice = {
    for (final label in [...prayerLabels, ...optionalNotificationLabels])
      label: 'default',
  };

  PrayerTimes? _today;
  DateTime? _cachedForDate;

  /// Cache of computed [PrayerTimes] for dates other than today, keyed by
  /// `yyyy-MM-dd`. Insertion order doubles as recency order (Dart's `Map`
  /// is a `LinkedHashMap`), so the oldest entry is always `keys.first`.
  final Map<String, PrayerTimes> _dateCache = {};

  // ── Init ─────────────────────────────────────────────────────────────────

  /// Idempotent for the one-time settings load, but the location
  /// acquisition below retries on every call while `locationGranted` is
  /// still false — safe to call from multiple screens/initStates, and
  /// also as a "retry" from a permission-denied prompt.
  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
      await _loadSettings();
    }

    if (locationGranted) return;

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
      permissionPermanentlyDenied =
          await LocationService.isPermissionDeniedForever();
      _loading = false;
      notifyListeners();
      return;
    }
    permissionPermanentlyDenied = false;

    try {
      coordinates = await LocationService.getCurrentCoordinates();
      locationError = false;
    } catch (_) {
      locationError = true;
    }
    _recompute();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    hijriOffsetDays = prefs.getInt(_kHijriOffsetKey) ?? 0;
    madhab =
        prefs.getString(_kMadhabKey) == 'shafi' ? Madhab.shafi : Madhab.hanafi;
    hijriDayStart = prefs.getString(_kHijriDayStartKey) == 'sunset'
        ? HijriDayStart.sunset
        : HijriDayStart.midnight;
    for (final label in prayerLabels) {
      prayerNotificationsEnabled[label] =
          prefs.getBool('$_kNotifyPrefixKey$label') ?? false;
    }
    for (final label in optionalNotificationLabels) {
      prayerNotificationsEnabled[label] =
          prefs.getBool('$_kNotifyPrefixKey$label') ?? false;
    }
    for (final label in [...prayerLabels, ...optionalNotificationLabels]) {
      prayerSoundChoice[label] =
          prefs.getString('$_kSoundPrefixKey$label') ?? 'default';
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

  /// hijriOffsetDays plus an automatic +1 when "day starts at Sunset" is
  /// selected and today's Maghrib has already passed — the value every
  /// Hijri-date display should use instead of the raw manual offset.
  int get displayHijriOffsetDays {
    var offset = hijriOffsetDays;
    final maghrib = today?.maghrib.toLocal();
    if (hijriDayStart == HijriDayStart.sunset &&
        maghrib != null &&
        DateTime.now().isAfter(maghrib)) {
      offset += 1;
    }
    return offset;
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

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Prayer times for an arbitrary date (past, today, or future), backed
  /// by a small bounded cache so repeated prev/next taps around the
  /// selected date don't recompute. Today always goes through [today]'s
  /// own freshness-checked slot instead of the date cache.
  PrayerTimes? prayerTimesForDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDate(date, now)) return today;

    final key = _dateKey(date);
    final cached = _dateCache.remove(key);
    if (cached != null) {
      _dateCache[key] = cached; // re-insert = mark most-recently-used
      return cached;
    }

    final computed = _prayerTimesFor(date);
    if (computed == null) return null;
    _dateCache[key] = computed;
    if (_dateCache.length > _kMaxDateCacheEntries) {
      _dateCache.remove(_dateCache.keys.first);
    }
    return computed;
  }

  /// [displayHijriOffsetDays]'s sunset-rollover rule, generalized to any
  /// date: for a past date "now" is always after its Maghrib (so the
  /// sunset-start Hijri day has fully elapsed → +1); for a future date
  /// it never is (no rollover yet); for today this matches the original
  /// today-only check exactly.
  int hijriOffsetForDate(DateTime date) {
    var offset = hijriOffsetDays;
    if (hijriDayStart == HijriDayStart.sunset) {
      final maghrib = prayerTimesForDate(date)?.maghrib.toLocal();
      if (maghrib != null && DateTime.now().isAfter(maghrib)) offset += 1;
    }
    return offset;
  }

  /// [displayPrayerWindows], generalized to any date.
  List<({String name, DateTime start, DateTime end})> windowsForDate(
      DateTime date) {
    final times = prayerTimesForDate(date);
    if (times == null) return const [];
    final yesterday =
        prayerTimesForDate(date.subtract(const Duration(days: 1)));
    return _buildWindows(times, yesterday);
  }

  /// Single window for [label] (any name from [windowsForDate]). Tahajjud
  /// always resolves to the trailing (upcoming) instance — same instance
  /// AlarmScheduler.computeUpcoming arms — since [windowsForDate] always
  /// ends with that date's own Tahajjud window.
  ({DateTime start, DateTime end})? windowForLabel(String label,
      {DateTime? date}) {
    final windows = windowsForDate(date ?? DateTime.now());
    if (windows.isEmpty) return null;
    if (label == 'Tahajjud') {
      final w = windows.last;
      return (start: w.start, end: w.end);
    }
    for (final w in windows) {
      if (w.name == label) return (start: w.start, end: w.end);
    }
    return null;
  }

  /// [displayPrayerWindows], generalized to any date — Tahajjud appears
  /// once (that date's morning instance), no trailing duplicate.
  List<({String name, DateTime start, DateTime end})>
      displayPrayerWindowsForDate(DateTime date) {
    final windows = windowsForDate(date);
    if (windows.isEmpty) return windows;
    return windows.sublist(0, windows.length - 1);
  }

  /// [forbiddenPeriods], generalized to any date.
  List<ForbiddenPeriod> forbiddenPeriodsForDate(DateTime date) {
    final times = prayerTimesForDate(date);
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

  /// The forbidden period active *right now*, if [date] is today and the
  /// current moment falls inside one of that date's windows — "active"
  /// only ever means "now", so non-today dates never return one.
  ForbiddenPeriod? activeForbiddenPeriodForDate(DateTime date) {
    final now = DateTime.now();
    if (!_isSameDate(date, now)) return null;
    for (final period in forbiddenPeriodsForDate(date)) {
      if (period.contains(now)) return period;
    }
    return null;
  }

  /// Builds the unified Tahajjud/Fajr/Ishraq/Chasht/Dhuhr/Asr/Maghrib/Isha
  /// cycle for [times]'s calendar date. [yesterday] (if available) supplies
  /// the leading Tahajjud window (last night's last-third-of-night -> this
  /// Fajr); the trailing Tahajjud window (tonight's last-third-of-night ->
  /// tomorrow's Fajr) is always derived from [times] itself. Fajr's window
  /// runs through to Ishraq's start (sunrise + 15min, matching the
  /// existing Sunrise-forbidden window's end) rather than stopping at
  /// sunrise, so there's never a "no current prayer" gap during that
  /// forbidden window.
  ///
  /// Isha's own window still ends at middle-of-night (unchanged), while
  /// Tahajjud doesn't start until last-third-of-night — there is an
  /// intentional gap between the two with no covering window. Callers of
  /// [currentPrayer]/[nextPrayerPeriod] must handle a `null` result during
  /// that gap; the dashboard card hides itself then rather than crashing.
  List<({String name, DateTime start, DateTime end})> _buildWindows(
      PrayerTimes times, PrayerTimes? yesterday) {
    final sunrise = times.sunrise.toLocal();
    final dhuhr = times.dhuhr.toLocal();
    final ishraqStart = sunrise.add(const Duration(minutes: 15));
    final chashtStart = sunrise.add(
        Duration(microseconds: dhuhr.difference(sunrise).inMicroseconds ~/ 2));
    final ishaEnd = SunnahTimes(times).middleOfTheNight.toLocal();
    final tahajjudStart = SunnahTimes(times).lastThirdOfTheNight.toLocal();

    return [
      if (yesterday != null)
        (
          name: 'Tahajjud',
          start: SunnahTimes(yesterday).lastThirdOfTheNight.toLocal(),
          end: times.fajr.toLocal(),
        ),
      (name: 'Fajr', start: times.fajr.toLocal(), end: ishraqStart),
      (name: 'Ishraq', start: ishraqStart, end: chashtStart),
      (name: 'Chasht', start: chashtStart, end: dhuhr),
      (name: 'Dhuhr', start: dhuhr, end: times.asr.toLocal()),
      (name: 'Asr', start: times.asr.toLocal(), end: times.maghrib.toLocal()),
      (
        name: 'Maghrib',
        start: times.maghrib.toLocal(),
        end: times.isha.toLocal()
      ),
      (name: 'Isha', start: times.isha.toLocal(), end: ishaEnd),
      (name: 'Tahajjud', start: tahajjudStart, end: times.fajrAfter.toLocal()),
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
  List<({String name, DateTime start, DateTime end})> get displayPrayerWindows {
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
    for (final w in windows) {
      if (now.isBefore(w.start)) {
        return (
          name: w.name,
          start: w.start,
          end: w.end,
          startsIn: w.start.difference(now),
        );
      }
    }
    return null;
  }

  /// Today's Sehri-end (Fajr) / Iftar (Maghrib) with a countdown that
  /// flips to tomorrow's schedule once today's Iftar has passed, or null
  /// if location hasn't been resolved yet.
  /// `isToday` distinguishes "Today's Schedule" (countdown to Iftar) from
  /// "Tomorrow's Schedule" (countdown to Sehri end) — display strings are
  /// resolved by the widget via l10n, this getter stays locale-agnostic.
  ({
    bool isToday,
    DateTime sehriEnd,
    DateTime iftar,
    Duration countdown
  })? get sehriIftarInfo {
    final times = today;
    if (times == null) return null;
    final now = DateTime.now();
    final iftarToday = times.maghrib.toLocal();
    if (now.isBefore(iftarToday)) {
      return (
        isToday: true,
        sehriEnd: times.fajr.toLocal(),
        iftar: iftarToday,
        countdown: iftarToday.difference(now),
      );
    }
    final tomorrow = _prayerTimesFor(now.add(const Duration(days: 1)));
    if (tomorrow == null) return null;
    final sehriEndTomorrow = times.fajrAfter.toLocal();
    return (
      isToday: false,
      sehriEnd: sehriEndTomorrow,
      iftar: tomorrow.maghrib.toLocal(),
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

  /// Opens the app's system Settings page — the only way out once
  /// [permissionPermanentlyDenied] is true, since the OS won't show the
  /// permission dialog again.
  Future<void> openLocationSettings() => LocationService.openAppSettings();

  Future<void> setHijriOffset(int offset) async {
    hijriOffsetDays = offset.clamp(-1, 1);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHijriOffsetKey, hijriOffsetDays);
  }

  Future<void> setHijriDayStart(HijriDayStart value) async {
    hijriDayStart = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHijriDayStartKey,
        value == HijriDayStart.sunset ? 'sunset' : 'midnight');
  }

  Future<void> setMadhab(Madhab value, {required Locale locale}) async {
    madhab = value;
    _recompute();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kMadhabKey, value == Madhab.shafi ? 'shafi' : 'hanafi');
    await _rescheduleNotifications(locale);
  }

  Future<void> setPrayerNotification(String label, bool enabled,
      {required Locale locale}) async {
    prayerNotificationsEnabled[label] = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kNotifyPrefixKey$label', enabled);
    await _rescheduleNotifications(locale);
  }

  Future<void> setPrayerSound(String label, String value,
      {required Locale locale}) async {
    prayerSoundChoice[label] = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kSoundPrefixKey$label', value);
    await _rescheduleNotifications(locale);
  }

  Future<void> _rescheduleNotifications(Locale locale) async {
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
      locale: locale,
      soundChoice: prayerSoundChoice,
      tahajjudToday: find(todayWindows, 'Tahajjud'),
      tahajjudTomorrow: find(tomorrowWindows, 'Tahajjud'),
      ishraqToday: find(todayWindows, 'Ishraq'),
      ishraqTomorrow: find(tomorrowWindows, 'Ishraq'),
      chashtToday: find(todayWindows, 'Chasht'),
      chashtTomorrow: find(tomorrowWindows, 'Chasht'),
    );
  }
}

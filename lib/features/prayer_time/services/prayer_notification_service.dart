// lib/features/prayer_time/services/prayer_notification_service.dart
//
// Wraps flutter_local_notifications + timezone setup and schedules one
// notification per enabled prayer for today and tomorrow. Prayer times
// shift daily, so callers must re-invoke scheduleForDay whenever the app
// is opened/resumed to keep the schedule accurate — there is no
// background rescheduling (out of scope; see module plan).

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:dhikir_app/core/l10n/prayer_localization.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

const _kChannelId = 'prayer_times';
const _kSilentChannelId = 'prayer_times_silent';

/// Fixed notification IDs: one slot per prayer for today (0-4) and
/// tomorrow (5-9), so rescheduling just overwrites the same IDs.
/// Tahajjud (not a `Prayer` enum value — derived via SunnahTimes) gets
/// its own fixed slots 10 (today) / 11 (tomorrow).
const _prayerOrder = [
  adhan.Prayer.fajr,
  adhan.Prayer.dhuhr,
  adhan.Prayer.asr,
  adhan.Prayer.maghrib,
  adhan.Prayer.isha,
];

const _kTahajjudLabel = 'Tahajjud';

class PrayerNotificationService {
  PrayerNotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initializes timezones + the notification plugin. Safe to call
  /// repeatedly; only runs once.
  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidInit = AndroidInitializationSettings('ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );

    _initialized = true;
  }

  /// Whether this app currently has permission to post notifications.
  static Future<bool> hasPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.areNotificationsEnabled() ?? false;
  }

  /// Prompts for notification permission if not already granted. Returns
  /// whether permission ended up granted.
  static Future<bool> requestPermission() async {
    if (!_initialized) await init();
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    if (granted != null && granted) {
      await androidPlugin?.requestExactAlarmsPermission();
    }
    return granted ?? await hasPermission();
  }

  static Future<bool> requestAlarmPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestExactAlarmsPermission();

    return granted ?? await hasPermission();
  }

  static NotificationDetails _detailsFor(
      String label, Map<String, String> soundChoice, AppLocalizations l10n) {
    final silent = soundChoice[label] == 'silent';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        silent ? _kSilentChannelId : _kChannelId,
        silent ? l10n.notifSilentChannelName : l10n.notifChannelName,
        channelDescription:
            silent ? l10n.notifSilentChannelDescription : l10n.notifChannelDescription,
        playSound: !silent,
      ),
    );
  }

  /// Cancels previously-scheduled prayer notifications and schedules fresh
  /// ones for [today] and the following day, honoring [enabled] per prayer
  /// (keyed by [adhan.Prayer.displayName], e.g. "Fajr").
  static Future<void> scheduleForDay({
    required adhan.PrayerTimes today,
    required adhan.PrayerTimes tomorrow,
    required Map<String, bool> enabled,
    required Locale locale,
    Map<String, String> soundChoice = const {},
    DateTime? tahajjudToday,
    DateTime? tahajjudTomorrow,
    DateTime? ishraqToday,
    DateTime? ishraqTomorrow,
    DateTime? chashtToday,
    DateTime? chashtTomorrow,
  }) async {
    if (!_initialized) await init();
    await _plugin.cancelAll();

    final l10n = lookupAppLocalizations(locale);

    var id = 0;
    for (final times in [today, tomorrow]) {
      for (final prayer in _prayerOrder) {
        final label = prayer.displayName;
        if (enabled[label] == false) {
          id++;
          continue;
        }

        final time = times.timeForPrayer(prayer).toLocal();
        final scheduled = tz.TZDateTime.from(time, tz.local);
        if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
          id++;
          continue;
        }

        final displayName = prayerDisplayNameFor(l10n, label);
        await _plugin.zonedSchedule(
          id: id,
          title: l10n.notifPrayerTitle(displayName),
          body: l10n.notifPrayerBody(displayName),
          scheduledDate: scheduled,
          notificationDetails: _detailsFor(label, soundChoice, l10n),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        id++;
      }
    }

    final optional = <(String, DateTime?, DateTime?, int)>[
      (_kTahajjudLabel, tahajjudToday, tahajjudTomorrow, 10),
      ('Ishraq', ishraqToday, ishraqTomorrow, 12),
      ('Chasht', chashtToday, chashtTomorrow, 14),
    ];
    for (final (label, todayTime, tomorrowTime, idBase) in optional) {
      if (enabled[label] != true) continue;
      final displayName = prayerDisplayNameFor(l10n, label);
      var optionalId = idBase;
      for (final time in [todayTime, tomorrowTime]) {
        if (time != null) {
          final scheduled = tz.TZDateTime.from(time, tz.local);
          if (!scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
            await _plugin.zonedSchedule(
              id: optionalId,
              title: displayName,
              body: l10n.notifOptionalBody(displayName),
              scheduledDate: scheduled,
              notificationDetails: _detailsFor(label, soundChoice, l10n),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          }
        }
        optionalId++;
      }
    }
  }
}

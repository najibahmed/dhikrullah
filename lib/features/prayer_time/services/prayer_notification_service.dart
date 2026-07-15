// lib/features/prayer_time/services/prayer_notification_service.dart
//
// Wraps flutter_local_notifications + timezone setup and schedules one
// notification per enabled prayer for today and tomorrow. Prayer times
// shift daily, so callers must re-invoke scheduleForDay whenever the app
// is opened/resumed to keep the schedule accurate — there is no
// background rescheduling (out of scope; see module plan).

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _kChannelId = 'prayer_times';
const _kChannelName = 'Prayer time reminders';
const _kChannelDescription = 'Notifies you at the start of each prayer time';

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

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// Cancels previously-scheduled prayer notifications and schedules fresh
  /// ones for [today] and the following day, honoring [enabled] per prayer
  /// (keyed by [adhan.Prayer.displayName], e.g. "Fajr").
  static Future<void> scheduleForDay({
    required adhan.PrayerTimes today,
    required adhan.PrayerTimes tomorrow,
    required Map<String, bool> enabled,
    DateTime? tahajjudToday,
    DateTime? tahajjudTomorrow,
    DateTime? ishraqToday,
    DateTime? ishraqTomorrow,
    DateTime? chashtToday,
    DateTime? chashtTomorrow,
  }) async {
    if (!_initialized) return;
    await _plugin.cancelAll();

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

        await _plugin.zonedSchedule(
          id: id,
          title: '$label prayer time',
          body: "It's time for $label.",
          scheduledDate: scheduled,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _kChannelId,
              _kChannelName,
              channelDescription: _kChannelDescription,
            ),
          ),
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
      var optionalId = idBase;
      for (final time in [todayTime, tomorrowTime]) {
        if (time != null) {
          final scheduled = tz.TZDateTime.from(time, tz.local);
          if (!scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
            await _plugin.zonedSchedule(
              id: optionalId,
              title: label,
              body: 'Time for $label.',
              scheduledDate: scheduled,
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  _kChannelId,
                  _kChannelName,
                  channelDescription: _kChannelDescription,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          }
        }
        optionalId++;
      }
    }
  }
}

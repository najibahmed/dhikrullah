// lib/features/alarm/services/alarm_scheduler.dart
//
// Converts prayer times (from the existing PrayerTimeProvider) plus
// each prayer's alarm offset into concrete alarm timestamps for today
// and tomorrow, and persists them for native BootReceiver restore.
// Never calculates prayer times itself — per alarm_api_contract.md,
// that stays owned by PrayerTimeProvider.

import 'dart:convert';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dhikir_app/features/alarm/models/scheduled_alarm.dart';
import 'package:dhikir_app/features/alarm/services/alarm_settings_repository.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';

const _kScheduledTimesKey = 'alarm_scheduled_times';

/// How many calendar days ahead to precompute alarm timestamps — "today
/// + tomorrow", i.e. up to ~48h out.
const kAlarmScheduleHorizonDays = 2;

const _obligatoryLabels = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

class AlarmScheduler {
  AlarmScheduler({
    required this.prayerTimeProvider,
    required this.settingsRepository,
  });

  final PrayerTimeProvider prayerTimeProvider;
  final AlarmSettingsRepository settingsRepository;

  DateTime _obligatoryTime(PrayerTimes times, String label) {
    switch (label) {
      case 'Fajr':
        return times.fajr.toLocal();
      case 'Dhuhr':
        return times.dhuhr.toLocal();
      case 'Asr':
        return times.asr.toLocal();
      case 'Maghrib':
        return times.maghrib.toLocal();
      case 'Isha':
        return times.isha.toLocal();
      default:
        throw ArgumentError('Not an obligatory prayer label: $label');
    }
  }

  /// Computes every enabled alarm-capable prayer's timestamp across
  /// [kAlarmScheduleHorizonDays] days starting at [from]'s calendar
  /// date, dropping anything not after [from]. Reads offsets from
  /// [settingsRepository]; reads prayer/Tahajjud times from
  /// [prayerTimeProvider] — no calculation happens here.
  Future<List<ScheduledAlarm>> computeUpcoming(DateTime from) async {
    final settings = await settingsRepository.getAll();
    final byId = {for (final s in settings) s.prayerId: s};
    final result = <ScheduledAlarm>[];

    for (var dayOffset = 0;
        dayOffset < kAlarmScheduleHorizonDays;
        dayOffset++) {
      final date = DateTime(from.year, from.month, from.day)
          .add(Duration(days: dayOffset));

      final times = prayerTimeProvider.prayerTimesForDate(date);
      if (times != null) {
        for (final label in _obligatoryLabels) {
          final setting = byId[label];
          if (setting == null || !setting.enabled) continue;
          final alarmTime = _obligatoryTime(times, label)
              .add(Duration(minutes: setting.offsetMinutes));
          if (alarmTime.isAfter(from)) {
            result.add(ScheduledAlarm(
              prayerId: label,
              epochMillis: alarmTime.millisecondsSinceEpoch,
            ));
          }
        }
      }

      final tahajjud = byId['Tahajjud'];
      if (tahajjud != null && tahajjud.enabled) {
        final windows = prayerTimeProvider.windowsForDate(date);
        // Trailing entry is always that date's own Tahajjud window
        // (last-third-of-night -> tomorrow's Fajr) — see
        // PrayerTimeProvider._buildWindows.
        if (windows.isNotEmpty) {
          final alarmTime = windows.last.start
              .add(Duration(minutes: tahajjud.offsetMinutes));
          if (alarmTime.isAfter(from)) {
            result.add(ScheduledAlarm(
              prayerId: 'Tahajjud',
              epochMillis: alarmTime.millisecondsSinceEpoch,
            ));
          }
        }
      }
    }

    result.sort((a, b) => a.epochMillis.compareTo(b.epochMillis));
    return result;
  }

  Future<void> persist(List<ScheduledAlarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kScheduledTimesKey,
      jsonEncode([for (final a in alarms) a.toJson()]),
    );
  }

  Future<List<ScheduledAlarm>> loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kScheduledTimesKey);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return [
      for (final entry in decoded)
        ScheduledAlarm.fromJson(entry as Map<String, dynamic>),
    ];
  }

  /// Computes upcoming alarms and persists them in one step — the entry
  /// point AlarmService calls on app open and whenever alarm settings
  /// change, before arming each timestamp via the native MethodChannel.
  Future<List<ScheduledAlarm>> scheduleUpcoming({DateTime? from}) async {
    final alarms = await computeUpcoming(from ?? DateTime.now());
    await persist(alarms);
    return alarms;
  }
}

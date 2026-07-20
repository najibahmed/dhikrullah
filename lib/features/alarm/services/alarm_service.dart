// lib/features/alarm/services/alarm_service.dart
//
// Primary Dart entry point for the alarm module (per alarm_api_contract.md).
// Bridges AlarmScheduler's computed timestamps to native exact alarms via
// AlarmMethodChannel, and exposes the exact-alarm / full-screen-intent
// permission flows from alarm_android_setup.md for the settings UI to drive.

import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:dhikir_app/features/alarm/models/scheduled_alarm.dart';
import 'package:dhikir_app/features/alarm/services/alarm_method_channel.dart';
import 'package:dhikir_app/features/alarm/services/alarm_scheduler.dart';

class AlarmService {
  AlarmService({
    required this.scheduler,
    AlarmMethodChannel? methodChannel,
  }) : methodChannel = methodChannel ?? AlarmMethodChannel();

  final AlarmScheduler scheduler;
  final AlarmMethodChannel methodChannel;

  Future<bool> canScheduleExactAlarms() {
    return methodChannel.canScheduleExactAlarms();
  }

  Future<void> openExactAlarmSettings() {
    return methodChannel.openExactAlarmSettings();
  }

  Future<bool> canUseFullScreenIntent() {
    return methodChannel.canUseFullScreenIntent();
  }

  Future<void> openFullScreenIntentSettings() {
    return methodChannel.openFullScreenIntentSettings();
  }

  /// Recomputes upcoming alarms from current settings/prayer times, persists
  /// them, and re-arms every one natively. Call on app open and whenever
  /// alarm settings change. A single prayer failing to arm (e.g. exact-alarm
  /// permission revoked) is logged and skipped rather than throwing — never
  /// crashes the caller, per alarm_api_contract.md's error contract.
  Future<List<ScheduledAlarm>> rescheduleAllPrayerAlarms({
    DateTime? from,
    required Locale locale,
  }) async {
    await methodChannel.cancelAllAlarms();
    final alarms =
        await scheduler.scheduleUpcoming(from: from, locale: locale);
    // alarms is sorted ascending by epochMillis and may contain both a
    // today and tomorrow occurrence for the same prayer — only arm the
    // nearest one, since AlarmArmer's PendingIntent identity is keyed by
    // prayerId alone and a second armAlarm() call for the same prayer
    // would silently replace (not add to) the first.
    final armedPrayerIds = <String>{};
    for (final alarm in alarms) {
      if (!armedPrayerIds.add(alarm.prayerId)) continue;
      try {
        await methodChannel.armAlarm(
            alarm.prayerId, alarm.epochMillis, alarm.label);
      } on PlatformException catch (e) {
        debugPrint('AlarmService: failed to arm ${alarm.prayerId}: ${e.message}');
      }
    }
    return alarms;
  }

  Future<void> cancelAllPrayerAlarms() {
    return methodChannel.cancelAllAlarms();
  }

  Future<void> cancelPrayerAlarm(String prayerId) {
    return methodChannel.cancelAlarm(prayerId);
  }
}

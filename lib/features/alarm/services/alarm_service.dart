// lib/features/alarm/services/alarm_service.dart
//
// Primary Dart entry point for the alarm module (per alarm_api_contract.md).
// Bridges AlarmScheduler's computed timestamps to native exact alarms via
// AlarmMethodChannel. Dismiss/isRunning arrive once ForegroundAlarmService
// exists (phase 4); fullscreen permission methods arrive with phase 6/7.

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

  /// Recomputes upcoming alarms from current settings/prayer times, persists
  /// them, and re-arms every one natively. Call on app open and whenever
  /// alarm settings change.
  Future<List<ScheduledAlarm>> rescheduleAllPrayerAlarms({DateTime? from}) async {
    await methodChannel.cancelAllAlarms();
    final alarms = await scheduler.scheduleUpcoming(from: from);
    for (final alarm in alarms) {
      await methodChannel.armAlarm(alarm.prayerId, alarm.epochMillis);
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

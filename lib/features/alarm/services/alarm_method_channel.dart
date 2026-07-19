// lib/features/alarm/services/alarm_method_channel.dart
//
// Dart side of the dhikir_app/alarm MethodChannel — thin wrapper over the
// native calls the Kotlin AlarmMethodChannel implements. No logic here
// beyond marshalling; owning when/what to arm is AlarmService's job.

import 'package:flutter/services.dart';

class AlarmMethodChannel {
  static const _channel = MethodChannel('dhikir_app/alarm');

  Future<void> armAlarm(String prayerId, int epochMillis) {
    return _channel.invokeMethod('armAlarm', {
      'prayerId': prayerId,
      'epochMillis': epochMillis,
    });
  }

  Future<void> cancelAlarm(String prayerId) {
    return _channel.invokeMethod('cancelAlarm', {'prayerId': prayerId});
  }

  Future<void> cancelAllAlarms() {
    return _channel.invokeMethod('cancelAllAlarms');
  }

  Future<bool> canScheduleExactAlarms() async {
    final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
    return result ?? false;
  }

  Future<void> openExactAlarmSettings() {
    return _channel.invokeMethod('openExactAlarmSettings');
  }

  Future<bool> canUseFullScreenIntent() async {
    final result = await _channel.invokeMethod<bool>('canUseFullScreenIntent');
    return result ?? false;
  }

  Future<void> openFullScreenIntentSettings() {
    return _channel.invokeMethod('openFullScreenIntentSettings');
  }
}

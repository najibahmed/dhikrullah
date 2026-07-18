// lib/features/alarm/models/scheduled_alarm.dart
//
// One armed alarm timestamp, persisted as JSON under the
// alarm_scheduled_times key so the native BootReceiver can re-arm
// future alarms after a reboot without recomputing prayer times (the
// alarm module must never calculate prayer times itself).

class ScheduledAlarm {
  /// Same string as [AlarmSettings.prayerId] / prayer label (`Fajr`..
  /// `Tahajjud`) — already human-readable, so it doubles as the native
  /// notification's display text.
  final String prayerId;
  final int epochMillis;

  const ScheduledAlarm({required this.prayerId, required this.epochMillis});

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(epochMillis);

  Map<String, dynamic> toJson() => {
        'prayerId': prayerId,
        'epochMillis': epochMillis,
      };

  factory ScheduledAlarm.fromJson(Map<String, dynamic> json) => ScheduledAlarm(
        prayerId: json['prayerId'] as String,
        epochMillis: json['epochMillis'] as int,
      );
}

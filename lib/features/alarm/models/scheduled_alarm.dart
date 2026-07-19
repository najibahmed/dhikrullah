// lib/features/alarm/models/scheduled_alarm.dart
//
// One armed alarm timestamp, persisted as JSON under the
// alarm_scheduled_times key so the native BootReceiver can re-arm
// future alarms after a reboot without recomputing prayer times (the
// alarm module must never calculate prayer times itself).

class ScheduledAlarm {
  /// Fixed English identifier (`Fajr`..`Tahajjud`) — used as the
  /// SharedPreferences key suffix and never localized.
  final String prayerId;
  final int epochMillis;

  /// Locale-aware display name (via `prayerDisplayNameFor`) shown as the
  /// native alarm notification's title — computed once at schedule time
  /// since native Kotlin has no access to Flutter's AppLocalizations.
  final String label;

  const ScheduledAlarm({
    required this.prayerId,
    required this.epochMillis,
    required this.label,
  });

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(epochMillis);

  Map<String, dynamic> toJson() => {
        'prayerId': prayerId,
        'epochMillis': epochMillis,
        'label': label,
      };

  factory ScheduledAlarm.fromJson(Map<String, dynamic> json) => ScheduledAlarm(
        prayerId: json['prayerId'] as String,
        epochMillis: json['epochMillis'] as int,
        label: json['label'] as String? ?? json['prayerId'] as String,
      );
}

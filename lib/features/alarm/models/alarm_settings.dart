// lib/features/alarm/models/alarm_settings.dart
//
// Per-prayer alarm configuration. Plain data class (not Hive) — persisted
// via AlarmSettingsRepository into SharedPreferences, one prayer at a
// time, per alarm_api_contract.md.

/// The 6 prayers the alarm module can arm — the 5 obligatory prayers plus
/// Tahajjud. Ishraq/Chasht are notification-only and never appear here.
const alarmPrayerLabels = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Tahajjud'];

/// Only bundled tone right now; kept as a string id so a future tone
/// picker doesn't require a model or storage-format change.
const kDefaultToneId = 'adhan_makkah';

const kAlarmOffsetMinMinutes = -60;
const kAlarmOffsetMaxMinutes = 60;
const kAlarmOffsetStepMinutes = 5;

class AlarmSettings {
  final String prayerId;
  final bool enabled;
  final int offsetMinutes;
  final bool vibrationEnabled;
  final bool fullscreenEnabled;
  final String toneId;

  const AlarmSettings({
    required this.prayerId,
    this.enabled = false,
    this.offsetMinutes = 0,
    this.vibrationEnabled = true,
    this.fullscreenEnabled = false,
    this.toneId = kDefaultToneId,
  });

  AlarmSettings copyWith({
    bool? enabled,
    int? offsetMinutes,
    bool? vibrationEnabled,
    bool? fullscreenEnabled,
    String? toneId,
  }) {
    return AlarmSettings(
      prayerId: prayerId,
      enabled: enabled ?? this.enabled,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      fullscreenEnabled: fullscreenEnabled ?? this.fullscreenEnabled,
      toneId: toneId ?? this.toneId,
    );
  }
}

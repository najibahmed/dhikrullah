// lib/features/alarm/services/alarm_settings_repository.dart
//
// Persists per-prayer AlarmSettings in SharedPreferences, following the
// same key-per-field pattern as PrayerTimeProvider's prayer_notify_/
// prayer_sound_ keys (see prayer_time_provider.dart). Keys and defaults
// are the compatibility contract documented in alarm_implementation.md —
// do not rename without updating that spec.

import 'package:shared_preferences/shared_preferences.dart';

import 'package:dhikir_app/features/alarm/models/alarm_settings.dart';

const _kEnabledPrefix = 'alarm_enabled_';
const _kOffsetPrefix = 'alarm_offset_';
const _kVibratePrefix = 'alarm_vibrate_';
const _kFullscreenPrefix = 'alarm_fullscreen_';

class AlarmSettingsRepository {
  /// Reads a single prayer's alarm settings, falling back to the
  /// documented defaults (enabled=false, offset=0, vibration=true,
  /// fullscreen=false, tone=athan) for anything not yet saved.
  Future<AlarmSettings> get(String prayerId) async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = AlarmSettings(prayerId: '');
    return AlarmSettings(
      prayerId: prayerId,
      enabled: prefs.getBool('$_kEnabledPrefix$prayerId') ?? defaults.enabled,
      offsetMinutes:
          prefs.getInt('$_kOffsetPrefix$prayerId') ?? defaults.offsetMinutes,
      vibrationEnabled: prefs.getBool('$_kVibratePrefix$prayerId') ??
          defaults.vibrationEnabled,
      fullscreenEnabled: prefs.getBool('$_kFullscreenPrefix$prayerId') ??
          defaults.fullscreenEnabled,
      toneId: kDefaultToneId,
    );
  }

  /// Reads every alarm-capable prayer's settings, in [alarmPrayerLabels] order.
  Future<List<AlarmSettings>> getAll() async {
    return [for (final label in alarmPrayerLabels) await get(label)];
  }

  /// Persists every field of [settings].
  Future<void> save(AlarmSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        '$_kEnabledPrefix${settings.prayerId}', settings.enabled);
    await prefs.setInt(
        '$_kOffsetPrefix${settings.prayerId}', settings.offsetMinutes);
    await prefs.setBool(
        '$_kVibratePrefix${settings.prayerId}', settings.vibrationEnabled);
    await prefs.setBool(
        '$_kFullscreenPrefix${settings.prayerId}', settings.fullscreenEnabled);
  }

  /// Reads, applies the given field changes, and persists — for
  /// single-field UI toggles (e.g. flipping just the alarm switch).
  Future<AlarmSettings> update(
    String prayerId, {
    bool? enabled,
    int? offsetMinutes,
    bool? vibrationEnabled,
    bool? fullscreenEnabled,
  }) async {
    final current = await get(prayerId);
    final updated = current.copyWith(
      enabled: enabled,
      offsetMinutes: offsetMinutes,
      vibrationEnabled: vibrationEnabled,
      fullscreenEnabled: fullscreenEnabled,
    );
    await save(updated);
    return updated;
  }

  /// Clears a prayer's alarm keys, reverting it to defaults.
  Future<void> delete(String prayerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kEnabledPrefix$prayerId');
    await prefs.remove('$_kOffsetPrefix$prayerId');
    await prefs.remove('$_kVibratePrefix$prayerId');
    await prefs.remove('$_kFullscreenPrefix$prayerId');
  }
}

// lib/features/alarm/widgets/alarm_settings_section.dart
//
// Embedded in the per-prayer bell bottom sheet (prayer_notification_bottom_
// sheet.dart), shown only for the 6 alarm-capable prayers. Owns its own
// AlarmSettingsRepository/AlarmService instances and local state — alarm
// settings aren't hoisted into the global Provider tree since only this
// section reads/writes them (per CLAUDE.md's screen-scoped-state rule).

import 'package:flutter/material.dart';

import 'package:dhikir_app/features/alarm/models/alarm_settings.dart';
import 'package:dhikir_app/features/alarm/services/alarm_scheduler.dart';
import 'package:dhikir_app/features/alarm/services/alarm_service.dart';
import 'package:dhikir_app/features/alarm/services/alarm_settings_repository.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';

class AlarmSettingsSection extends StatefulWidget {
  final String prayerId;
  final PrayerTimeProvider prayerTimeProvider;

  const AlarmSettingsSection({
    super.key,
    required this.prayerId,
    required this.prayerTimeProvider,
  });

  @override
  State<AlarmSettingsSection> createState() => _AlarmSettingsSectionState();
}

class _AlarmSettingsSectionState extends State<AlarmSettingsSection> {
  late final _repository = AlarmSettingsRepository();
  late final _alarmService = AlarmService(
    scheduler: AlarmScheduler(
      prayerTimeProvider: widget.prayerTimeProvider,
      settingsRepository: _repository,
    ),
  );

  AlarmSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _repository.get(widget.prayerId);
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _update({
    bool? enabled,
    int? offsetMinutes,
    bool? vibrationEnabled,
    bool? fullscreenEnabled,
  }) async {
    final updated = await _repository.update(
      widget.prayerId,
      enabled: enabled,
      offsetMinutes: offsetMinutes,
      vibrationEnabled: vibrationEnabled,
      fullscreenEnabled: fullscreenEnabled,
    );
    if (mounted) setState(() => _settings = updated);
    await _alarmService.rescheduleAllPrayerAlarms();
  }

  Future<void> _onToggleEnabled(bool value) async {
    await _update(enabled: value);
    if (!value || !mounted) return;
    final granted = await _alarmService.canScheduleExactAlarms();
    if (!granted && mounted) {
      await _showPermissionDialog(
        title: 'Exact alarms are off',
        body:
            'Allow exact alarms in system settings so this prayer alarm fires on time.',
        onOpenSettings: _alarmService.openExactAlarmSettings,
      );
    }
  }

  Future<void> _onToggleFullscreen(bool value) async {
    await _update(fullscreenEnabled: value);
    if (!value || !mounted) return;
    final granted = await _alarmService.canUseFullScreenIntent();
    if (!granted && mounted) {
      await _showPermissionDialog(
        title: 'Full-screen alerts are off',
        body:
            'Allow full-screen alerts in system settings so this alarm can show over the lock screen. It still rings as a notification either way.',
        onOpenSettings: _alarmService.openFullScreenIntentSettings,
      );
    }
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String body,
    required Future<void> Function() onOpenSettings,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onOpenSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _offsetLabel(int minutes) {
    if (minutes == 0) return 'On time';
    return minutes > 0 ? '+$minutes min' : '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text('Alarm',
            style:
                theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Full alarm with Adhan'),
          subtitle: Text(settings.enabled ? 'On' : 'Off'),
          value: settings.enabled,
          onChanged: _onToggleEnabled,
        ),
        if (settings.enabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Alarm time offset', style: theme.textTheme.bodyMedium),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: settings.offsetMinutes > kAlarmOffsetMinMinutes
                    ? () => _update(
                        offsetMinutes:
                            settings.offsetMinutes - kAlarmOffsetStepMinutes)
                    : null,
              ),
              SizedBox(
                width: 72,
                child: Text(
                  _offsetLabel(settings.offsetMinutes),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: settings.offsetMinutes < kAlarmOffsetMaxMinutes
                    ? () => _update(
                        offsetMinutes:
                            settings.offsetMinutes + kAlarmOffsetStepMinutes)
                    : null,
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vibration'),
            value: settings.vibrationEnabled,
            onChanged: (value) => _update(vibrationEnabled: value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Full-screen alarm'),
            subtitle: const Text('Show a lock-screen alert when the alarm fires'),
            value: settings.fullscreenEnabled,
            onChanged: _onToggleFullscreen,
          ),
        ],
      ],
    );
  }
}

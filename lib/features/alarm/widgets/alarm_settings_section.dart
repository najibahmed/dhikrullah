// lib/features/alarm/widgets/alarm_settings_section.dart
//
// Embedded in the per-prayer bell bottom sheet (prayer_notification_bottom_
// sheet.dart), shown only for the 6 alarm-capable prayers. Owns its own
// AlarmSettingsRepository/AlarmService instances and local state — alarm
// settings aren't hoisted into the global Provider tree since only this
// section reads/writes them (per CLAUDE.md's screen-scoped-state rule).

import 'package:flutter/material.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/utils/time_format.dart';
import 'package:dhikir_app/features/alarm/models/alarm_settings.dart';
import 'package:dhikir_app/features/alarm/services/alarm_scheduler.dart';
import 'package:dhikir_app/features/alarm/services/alarm_service.dart';
import 'package:dhikir_app/features/alarm/services/alarm_settings_repository.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

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
    final locale = Localizations.localeOf(context);
    final updated = await _repository.update(
      widget.prayerId,
      enabled: enabled,
      offsetMinutes: offsetMinutes,
      vibrationEnabled: vibrationEnabled,
      fullscreenEnabled: fullscreenEnabled,
    );
    if (mounted) setState(() => _settings = updated);
    await _alarmService.rescheduleAllPrayerAlarms(locale: locale);
  }

  Future<void> _onToggleEnabled(bool value) async {
    await _update(enabled: value);
    if (!value || !mounted) return;
    final granted = await _alarmService.canScheduleExactAlarms();
    if (!granted && mounted) {
      final l10n = context.l10n;
      await _showPermissionDialog(
        title: l10n.alarmExactPermissionTitle,
        body: l10n.alarmExactPermissionBody,
        onOpenSettings: _alarmService.openExactAlarmSettings,
      );
    }
  }

  Future<void> _onToggleFullscreen(bool value) async {
    await _update(fullscreenEnabled: value);
    if (!value || !mounted) return;
    final granted = await _alarmService.canUseFullScreenIntent();
    if (!granted && mounted) {
      final l10n = context.l10n;
      await _showPermissionDialog(
        title: l10n.alarmFullScreenPermissionTitle,
        body: l10n.alarmFullScreenPermissionBody,
        onOpenSettings: _alarmService.openFullScreenIntentSettings,
      );
    }
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String body,
    required Future<void> Function() onOpenSettings,
  }) {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.notNowButton),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onOpenSettings();
            },
            child: Text(l10n.openSettingsButton),
          ),
        ],
      ),
    );
  }

  DateTime? _alarmClockTime(int offsetMinutes) {
    final base = widget.prayerTimeProvider.windowForLabel(widget.prayerId)?.start;
    return base?.add(Duration(minutes: offsetMinutes));
  }

  String _offsetLabel(AppLocalizations l10n, int minutes) {
    if (minutes == 0) return l10n.alarmOffsetOnTime;
    return minutes > 0
        ? l10n.alarmOffsetMinutesPlus(minutes)
        : l10n.alarmOffsetMinutesMinus(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(l10n.alarmSectionTitle,
            style:
                theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.alarmFullWithAdhan),
          subtitle: Text(settings.enabled ? l10n.alarmStateOn : l10n.alarmStateOff),
          value: settings.enabled,
          onChanged: _onToggleEnabled,
        ),
        if (settings.enabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(l10n.alarmTimeOffset, style: theme.textTheme.bodyMedium),
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
                width: 90,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _offsetLabel(l10n, settings.offsetMinutes),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (_alarmClockTime(settings.offsetMinutes) case final time?)
                      Text(
                        formatClockTime(time),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
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
            title: Text(l10n.alarmVibration),
            value: settings.vibrationEnabled,
            onChanged: (value) => _update(vibrationEnabled: value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.alarmFullScreen),
            subtitle: Text(l10n.alarmFullScreenSubtitle),
            value: settings.fullscreenEnabled,
            onChanged: _onToggleFullscreen,
          ),
        ],
      ],
    );
  }
}

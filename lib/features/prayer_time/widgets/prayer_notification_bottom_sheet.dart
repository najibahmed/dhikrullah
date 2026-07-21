// lib/features/prayer_time/widgets/prayer_notification_bottom_sheet.dart
//
// Per-prayer notification control, opened by tapping a prayer row's bell
// icon on PrayerTimeScreen. First tap anywhere gates on OS notification
// permission (requesting it if not yet granted); once granted, the bell
// opens a 70%-height sheet with an on/off toggle and a sound choice for
// that specific prayer.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/utils/time_format.dart';
import 'package:dhikir_app/features/alarm/models/alarm_settings.dart';
import 'package:dhikir_app/features/alarm/widgets/alarm_settings_section.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/features/prayer_time/services/location_service.dart';
import 'package:dhikir_app/features/prayer_time/services/prayer_notification_service.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/l10n/prayer_localization.dart';

/// Entry point for a bell-icon tap: requests notification permission if
/// needed, then opens the sheet — or shows guidance if permission was
/// denied.
Future<void> handlePrayerBellTap(
  BuildContext context,
  String label,
) async {
  var granted = false;
  try {
    await PrayerNotificationService.init();

    granted = await PrayerNotificationService.hasPermission();
    if (!granted) {
      granted = await PrayerNotificationService.requestPermission();
    }
  } catch (e) {
    debugPrint('handlePrayerBellTap: permission flow failed: $e');
  }

  if (!context.mounted) return;

  if (!granted) {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.notifOffDialogTitle),
        content: Text(l10n.notifOffDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.notNowButton),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              LocationService.openAppSettings();
            },
            child: Text(l10n.openSettingsButton),
          ),
        ],
      ),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PrayerNotificationSheet(label: label),
  );
}

class _PrayerNotificationSheet extends StatelessWidget {
  final String label;

  const _PrayerNotificationSheet({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final provider = context.watch<PrayerTimeProvider>();
    final enabled = provider.prayerNotificationsEnabled[label] ?? true;
    final sound = provider.prayerSoundChoice[label] ?? 'default';
    final window = provider.windowForLabel(label);

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(prayerDisplayName(context, label), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),
                    if (window != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${formatClockTime(window.start)} - ${formatClockTime(window.end)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.notificationSwitchTitle),
                      subtitle: Text(enabled ? l10n.notificationOnSubtitle : l10n.notificationOffSubtitle),
                      value: enabled,
                      onChanged: (value) => provider.setPrayerNotification(label, value, locale: Localizations.localeOf(context)),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.soundSection, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _soundOption(context, theme, provider, label: l10n.soundDefault, value: 'default', selected: sound),
                    const SizedBox(height: 8),
                    _soundOption(context, theme, provider, label: l10n.soundSilent, value: 'silent', selected: sound),
                    if (alarmPrayerLabels.contains(label)) AlarmSettingsSection(prayerId: label, prayerTimeProvider: provider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _soundOption(
    BuildContext context,
    ThemeData theme,
    PrayerTimeProvider provider, {
    required String label,
    required String value,
    required String selected,
  }) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => provider.setPrayerSound(this.label, value, locale: Localizations.localeOf(context)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.secondary.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            if (isSelected)
              CircleAvatar(
                radius: 10,
                backgroundColor: theme.colorScheme.secondary,
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

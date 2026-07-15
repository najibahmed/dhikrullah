// lib/features/prayer_time/widgets/prayer_notification_bottom_sheet.dart
//
// Per-prayer notification control, opened by tapping a prayer row's bell
// icon on PrayerTimeScreen. First tap anywhere gates on OS notification
// permission (requesting it if not yet granted); once granted, the bell
// opens a 70%-height sheet with an on/off toggle and a sound choice for
// that specific prayer.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/features/prayer_time/services/location_service.dart';
import 'package:dhikir_app/features/prayer_time/services/prayer_notification_service.dart';

/// Entry point for a bell-icon tap: requests notification permission if
/// needed, then opens the sheet — or shows guidance if permission was
/// denied.
Future<void> handlePrayerBellTap(
  BuildContext context,
  String label,
) async {
  await PrayerNotificationService.init();

  var granted = await PrayerNotificationService.hasPermission();
  if (!granted) {
    granted = await PrayerNotificationService.requestPermission();
  }

  if (!context.mounted) return;

  if (!granted) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notifications are off'),
        content: const Text(
          'To get prayer time reminders, allow notifications for this app '
          'in system settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              LocationService.openAppSettings();
            },
            child: const Text('Open Settings'),
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
    final provider = context.watch<PrayerTimeProvider>();
    final enabled = provider.prayerNotificationsEnabled[label] ?? true;
    final sound = provider.prayerSoundChoice[label] ?? 'default';

    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
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
              const SizedBox(height: 20),
              Text(label,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notification'),
                subtitle: Text(
                    enabled ? 'You will be notified' : 'Notification is off'),
                value: enabled,
                onChanged: (value) =>
                    provider.setPrayerNotification(label, value),
              ),
              const SizedBox(height: 16),
              Text('Sound',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _soundOption(context, theme, provider,
                  label: 'Default', value: 'default', selected: sound),
              const SizedBox(height: 8),
              _soundOption(context, theme, provider,
                  label: 'Silent', value: 'silent', selected: sound),
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
      onTap: () => provider.setPrayerSound(this.label, value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary.withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.secondary
                : theme.dividerColor.withValues(alpha: 0.4),
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

// lib/features/prayer_time/screens/prayer_time_settings_screen.dart
//
// Combined prayer settings page: per-prayer + Tahajjud notification
// toggles, and the Madhab (Asr calculation) picker. Reached from the
// gear icon on PrayerTimeScreen's AppBar — moved out of that screen so
// the main page stays focused on a single date's prayer times.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/l10n/prayer_localization.dart';

class PrayerTimeSettingsScreen extends StatelessWidget {
  const PrayerTimeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.prayerSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _NotificationSettingsSection(provider: provider),
          const Divider(height: 32),
          _MadhabSection(provider: provider),
        ],
      ),
    );
  }
}

class _NotificationSettingsSection extends StatelessWidget {
  final PrayerTimeProvider provider;

  const _NotificationSettingsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.notificationsSectionTitle,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        for (final label in prayerLabels)
          SwitchListTile(
            title: Text(prayerDisplayName(context, label)),
            value: provider.prayerNotificationsEnabled[label] ?? true,
            onChanged: (value) => provider.setPrayerNotification(label, value,
                locale: Localizations.localeOf(context)),
          ),
        for (final label in optionalNotificationLabels)
          SwitchListTile(
            title: Text(prayerDisplayName(context, label)),
            subtitle: Text(l10n.notificationsOptionalSubtitle),
            value: provider.prayerNotificationsEnabled[label] ?? false,
            onChanged: (value) => provider.setPrayerNotification(label, value,
                locale: Localizations.localeOf(context)),
          ),
      ],
    );
  }
}

class _MadhabSection extends StatelessWidget {
  final PrayerTimeProvider provider;

  const _MadhabSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.madhabSection,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<Madhab>(
            segments: [
              ButtonSegment(value: Madhab.hanafi, label: Text(l10n.madhabHanafi)),
              ButtonSegment(value: Madhab.shafi, label: Text(l10n.madhabShafi)),
            ],
            selected: {provider.madhab},
            onSelectionChanged: (selection) => provider.setMadhab(
                selection.first,
                locale: Localizations.localeOf(context)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

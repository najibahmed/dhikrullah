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

class PrayerTimeSettingsScreen extends StatelessWidget {
  const PrayerTimeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Settings')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Notifications',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        for (final label in prayerLabels)
          SwitchListTile(
            title: Text(label),
            value: provider.prayerNotificationsEnabled[label] ?? true,
            onChanged: (value) => provider.setPrayerNotification(label, value),
          ),
        for (final label in optionalNotificationLabels)
          SwitchListTile(
            title: Text(label),
            subtitle: const Text('Optional — off by default'),
            value: provider.prayerNotificationsEnabled[label] ?? false,
            onChanged: (value) => provider.setPrayerNotification(label, value),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Madhab (Asr calculation)',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<Madhab>(
            segments: const [
              ButtonSegment(value: Madhab.hanafi, label: Text('Hanafi')),
              ButtonSegment(value: Madhab.shafi, label: Text('Shafi')),
            ],
            selected: {provider.madhab},
            onSelectionChanged: (selection) =>
                provider.setMadhab(selection.first),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// lib/features/prayer_time/screens/prayer_time_screen.dart
//
// Full prayer time detail screen: date header, all 5 prayer times with
// the current/next one highlighted, and a settings section (per-prayer
// notification toggle + Hijri day-offset control).

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/widgets/date_header_row.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';

const _prayerOrder = [
  Prayer.fajr,
  Prayer.sunrise,
  Prayer.dhuhr,
  Prayer.asr,
  Prayer.maghrib,
  Prayer.isha,
];

class PrayerTimeScreen extends StatelessWidget {
  const PrayerTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PrayerTimeProvider>();
    final times = provider.today;

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          DateHeaderRow(hijriOffsetDays: provider.hijriOffsetDays),
          const SizedBox(height: 8),

          if (!provider.locationGranted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location permission is required to calculate prayer times.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => provider.init(),
                    child: const Text('Enable location'),
                  ),
                ],
              ),
            )
          else if (times == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _PrayerListSection(times: times, provider: provider),
            const Divider(height: 32),
            _NotificationSettingsSection(provider: provider),
            const Divider(height: 32),
            _HijriOffsetSection(provider: provider),
          ],
        ],
      ),
    );
  }
}

class _PrayerListSection extends StatelessWidget {
  final PrayerTimes times;
  final PrayerTimeProvider provider;

  const _PrayerListSection({required this.times, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = times.nextPrayer();

    return Column(
      children: [
        for (final prayer in _prayerOrder)
          ListTile(
            leading: Icon(
              prayer == next ? Icons.mosque : Icons.mosque_outlined,
              color: prayer == next ? theme.colorScheme.primary : null,
            ),
            title: Text(
              prayer.displayName,
              style: prayer == next
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    )
                  : theme.textTheme.titleMedium,
            ),
            trailing: Text(
              TimeOfDay.fromDateTime(times.timeForPrayer(prayer).toLocal())
                  .format(context),
              style: theme.textTheme.titleMedium,
            ),
          ),
      ],
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
          child: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        for (final label in prayerLabels)
          SwitchListTile(
            title: Text(label),
            value: provider.prayerNotificationsEnabled[label] ?? true,
            onChanged: (value) => provider.setPrayerNotification(label, value),
          ),
      ],
    );
  }
}

class _HijriOffsetSection extends StatelessWidget {
  final PrayerTimeProvider provider;

  const _HijriOffsetSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hijri date adjustment', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Shift by a day if it doesn\'t match your local moon-sighting announcement.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: -1, label: Text('-1')),
              ButtonSegment(value: 0, label: Text('0')),
              ButtonSegment(value: 1, label: Text('+1')),
            ],
            selected: {provider.hijriOffsetDays},
            onSelectionChanged: (selection) =>
                provider.setHijriOffset(selection.first),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

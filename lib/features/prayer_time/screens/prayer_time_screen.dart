// lib/features/prayer_time/screens/prayer_time_screen.dart
//
// Full prayer time detail screen: date header, all 6 prayer times with
// a 3-state (completed/current/upcoming) indicator, additional daily
// info (sunrise/sunset/Sehri/Iftar/night-third/Tahajjud/Qiyam),
// forbidden-time windows, and a settings section (Madhab, per-prayer +
// Tahajjud notification toggles, Hijri day-offset control).

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/widgets/date_header_row.dart';
import 'package:dhikir_app/features/prayer_time/models/forbidden_period.dart';
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
          // DateHeaderRow(hijriOffsetDays: provider.hijriOffsetDays),
          // const SizedBox(height: 8),

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
            _AdditionalInfoSection(times: times),
            const Divider(height: 32),
            _ForbiddenTimesSection(provider: provider),
            const Divider(height: 32),
            _NotificationSettingsSection(provider: provider),
            const Divider(height: 32),
            _MadhabSection(provider: provider),
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
    final now = DateTime.now();
    final current = provider.isTahajjudTime ? null : times.currentPrayer();

    final active = provider.activeForbiddenPeriod;

    return Column(
      children: [
        for (var i = 0; i < _prayerOrder.length; i++)
          Builder(builder: (context) {
            final prayer = _prayerOrder[i];
            final isCurrent = prayer == current;
            final isCompleted = !isCurrent &&
                now.isAfter(times.timeForPrayer(prayer).toLocal());

            final IconData icon;
            final Color? color;
            if (isCurrent) {
              icon = Icons.mosque;
              color = theme.colorScheme.primary;
            } else if (isCompleted) {
              icon = Icons.check_circle;
              color = theme.colorScheme.onSurface.withValues(alpha: 0.4);
            } else {
              icon = Icons.circle_outlined;
              color = theme.colorScheme.onSurface.withValues(alpha: 0.4);
            }

            Widget? warning;
            if (active != null && i < _prayerOrder.length - 1) {
              final gapStart = times.timeForPrayer(prayer).toLocal();
              final gapEnd = times.timeForPrayer(_prayerOrder[i + 1]).toLocal();
              if (!active.start.isBefore(gapStart) &&
                  active.start.isBefore(gapEnd)) {
                warning = _ForbiddenWarningCard(period: active);
              }
            }

            return Column(
              children: [
                ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(
                    prayer.displayName,
                    style: isCurrent
                        ? theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          )
                        : theme.textTheme.titleMedium,
                  ),
                  trailing: Text(
                    TimeOfDay.fromDateTime(
                            times.timeForPrayer(prayer).toLocal())
                        .format(context),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (warning != null) warning,
              ],
            );
          }),
      ],
    );
  }
}

class _ForbiddenWarningCard extends StatelessWidget {
  final ForbiddenPeriod period;

  const _ForbiddenWarningCard({required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.error, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.block, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forbidden time · ${period.name}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  Text(
                    'Until ${TimeOfDay.fromDateTime(period.end).format(context)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdditionalInfoSection extends StatelessWidget {
  final PrayerTimes times;

  const _AdditionalInfoSection({required this.times});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sunnah = SunnahTimes(times);

    Widget row(String label, DateTime time) => ListTile(
          dense: true,
          title: Text(label, style: theme.textTheme.bodyMedium),
          trailing: Text(
            TimeOfDay.fromDateTime(time.toLocal()).format(context),
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Additional Info',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        row('Sunrise', times.sunrise),
        row('Sunset', times.sunset),
        row('Sehri ends', times.fajr),
        row('Iftar', times.maghrib),
        row('Middle of night', sunnah.middleOfTheNight),
        row('Last third of night', sunnah.lastThirdOfTheNight),
        row('Tahajjud starts', sunnah.middleOfTheNight),
        row('Qiyam', sunnah.lastThirdOfTheNight),
      ],
    );
  }
}

class _ForbiddenTimesSection extends StatelessWidget {
  final PrayerTimeProvider provider;

  const _ForbiddenTimesSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = provider.activeForbiddenPeriod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Forbidden Times',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        for (final period in provider.forbiddenPeriods)
          ListTile(
            dense: true,
            leading: Icon(
              Icons.block,
              color: period == active
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            title: Text(
              period.name,
              style: period == active
                  ? theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    )
                  : theme.textTheme.bodyMedium,
            ),
            trailing: Text(
              '${TimeOfDay.fromDateTime(period.start).format(context)} – '
              '${TimeOfDay.fromDateTime(period.end).format(context)}',
              style: theme.textTheme.bodySmall,
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
          const Text('Hijri date adjustment',
              style: TextStyle(fontWeight: FontWeight.w700)),
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

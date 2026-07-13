// lib/features/prayer_time/widgets/prayer_time_card.dart
//
// Compact home-dashboard card. Branches on PrayerTimeProvider.status to
// show a location prompt, a loading/error placeholder, the current
// forbidden window, or the normal current-prayer layout (with a
// before-Fajr and a Ramadan Sehri/Iftar variant). Tapping opens the full
// prayer time detail screen. Countdown ticking is screen-local state
// (Timer.periodic + setState), not provider state.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';

class PrayerTimeCard extends StatefulWidget {
  const PrayerTimeCard({super.key});

  @override
  State<PrayerTimeCard> createState() => _PrayerTimeCardState();
}

class _PrayerTimeCardState extends State<PrayerTimeCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration d) {
    final positive = d.isNegative ? Duration.zero : d;
    final hours = positive.inHours;
    final minutes = positive.inMinutes % 60;
    if (hours > 0) return 'in ${hours}h ${minutes}m';
    return 'in ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PrayerTimeProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Semantics(
        button: true,
        label: _semanticLabel(provider),
        child: GestureDetector(
          onTap: provider.locationGranted
              ? () => Navigator.pushNamed(context, RouteNames.prayerTime)
              : () => provider.init(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: ExcludeSemantics(child: _buildContent(context, theme, provider)),
          ),
        ),
      ),
    );
  }

  /// Screen-reader summary for the whole card, since [ExcludeSemantics]
  /// hides the individual Text/Icon children behind this single label.
  String _semanticLabel(PrayerTimeProvider provider) {
    switch (provider.status) {
      case PrayerStatus.gpsDisabled:
        return 'Prayer times unavailable. Enable device location.';
      case PrayerStatus.permissionRequired:
        return 'Prayer times unavailable. Enable location permission.';
      case PrayerStatus.locationUnavailable:
        return 'Prayer times unavailable. Unable to determine location.';
      case PrayerStatus.error:
        return 'Unable to calculate prayer times.';
      case PrayerStatus.loading:
        return 'Finding prayer times.';
      case PrayerStatus.forbidden:
        final period = provider.activeForbiddenPeriod;
        final next = provider.nextPrayer;
        return 'Forbidden prayer time: ${period?.name ?? ''}.'
            '${next != null ? ' Next prayer ${next.name}.' : ''}';
      case PrayerStatus.normal:
        final current = provider.currentPrayer;
        if (current == null) return 'Prayer times.';
        final percent = (current.progress * 100).round();
        return 'Current prayer ${current.name}, $percent percent through.';
    }
  }

  Widget _buildContent(BuildContext context, ThemeData theme, PrayerTimeProvider provider) {
    switch (provider.status) {
      case PrayerStatus.gpsDisabled:
        return _messageRow(
          theme,
          icon: Icons.location_disabled,
          text: 'Enable device location to see prayer times',
        );
      case PrayerStatus.permissionRequired:
        return _messageRow(
          theme,
          icon: Icons.location_on_outlined,
          text: 'Enable location to see prayer times',
        );
      case PrayerStatus.locationUnavailable:
        return _messageRow(
          theme,
          icon: Icons.location_off_outlined,
          text: 'Unable to determine location',
        );
      case PrayerStatus.error:
        return _messageRow(
          theme,
          icon: Icons.error_outline,
          text: 'Unable to calculate prayer times',
        );
      case PrayerStatus.loading:
        return Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Finding prayer times…', style: theme.textTheme.bodyMedium),
          ],
        );
      case PrayerStatus.forbidden:
        return _forbiddenRow(context, theme, provider);
      case PrayerStatus.normal:
        return _normalRow(context, theme, provider);
    }
  }

  Widget _messageRow(ThemeData theme, {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      ],
    );
  }

  Widget _forbiddenRow(BuildContext context, ThemeData theme, PrayerTimeProvider provider) {
    final period = provider.activeForbiddenPeriod!;
    final next = provider.nextPrayer;
    final remaining = period.end.difference(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forbidden time · ${period.name}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                ),
              ),
              Text('Ends ${_formatCountdown(remaining)}', style: theme.textTheme.bodySmall),
              if (next != null)
                Text(
                  'Next: ${next.name} ${_formatCountdown(next.time.difference(DateTime.now()))}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      ],
    );
  }

  Widget _normalRow(BuildContext context, ThemeData theme, PrayerTimeProvider provider) {
    final current = provider.currentPrayer!;
    final next = provider.nextPrayer;
    final times = provider.today!;
    final now = DateTime.now();

    final isBeforeFajr = now.isBefore(times.fajr.toLocal());
    if (isBeforeFajr) {
      final fajrRemaining = times.fajr.toLocal().difference(now);
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fajr starts ${_formatCountdown(fajrRemaining)}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Sehri ends at ${TimeOfDay.fromDateTime(times.fajr.toLocal()).format(context)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      );
    }

    final isRamadan = HijriCalendar.fromDate(
          now.add(Duration(days: provider.hijriOffsetDays)),
        ).hMonth ==
        9;
    final nextLabel = (isRamadan && next?.name == 'Maghrib') ? 'Iftar' : next?.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.mosque_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${TimeOfDay.fromDateTime(current.start).format(context)} – '
                      '${TimeOfDay.fromDateTime(current.end).format(context)} · '
                      '${_formatCountdown(current.end.difference(now))} left',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: current.progress, minHeight: 4),
        ),
        if (next != null) ...[
          const SizedBox(height: 8),
          Text(
            '$nextLabel ${_formatCountdown(next.time.difference(now))}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

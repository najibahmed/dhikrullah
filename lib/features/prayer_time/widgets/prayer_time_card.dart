// lib/features/prayer_time/widgets/prayer_time_card.dart
//
// Compact home-dashboard card: next prayer name + live countdown. Tapping
// opens the full prayer time detail screen. Countdown ticking is
// screen-local state (Timer.periodic + setState), not provider state.

import 'dart:async';

import 'package:flutter/material.dart';
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
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
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
          child: _buildContent(theme, provider),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, PrayerTimeProvider provider) {
    if (!provider.locationGranted) {
      return Row(
        children: [
          Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enable location to see prayer times',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      );
    }

    final next = provider.nextPrayer;
    if (next == null) {
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
    }

    final remaining = next.time.difference(DateTime.now());
    return Row(
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
                  'Next: ${next.name}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${TimeOfDay.fromDateTime(next.time).format(context)} · ${_formatCountdown(remaining)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      ],
    );
  }
}

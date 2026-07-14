// lib/features/prayer_time/widgets/forbidden_times_card.dart
//
// Home-dashboard card listing today's 3 disliked/forbidden prayer windows.
// Always shown whenever location is resolved, independent of PrayerStatus —
// unlike PrayerScheduleSection's cards, it stays visible during an active
// forbidden window since that's when it's most useful as a reference.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';

const _kLabels = [
  'Forbidden Time (Morning)',
  'Forbidden Time (Noon)',
  'Forbidden Time (Evening)',
];

class ForbiddenTimesCard extends StatelessWidget {
  const ForbiddenTimesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PrayerTimeProvider>();
    if (provider.today == null) return const SizedBox.shrink();

    final periods = provider.forbiddenPeriods;
    final active = provider.activeForbiddenPeriod;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.error, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Forbidden Times",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.error.withValues(alpha: 0.3)),
            const SizedBox(height: 4),
            for (var i = 0; i < periods.length && i < _kLabels.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _kLabels[i],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: periods[i] == active
                            ? theme.colorScheme.error
                            : theme.colorScheme.onErrorContainer,
                        fontWeight: periods[i] == active
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      '${TimeOfDay.fromDateTime(periods[i].start).format(context)} - '
                      '${TimeOfDay.fromDateTime(periods[i].end).format(context)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: periods[i] == active
                            ? theme.colorScheme.error
                            : theme.colorScheme.onErrorContainer,
                        fontWeight: periods[i] == active
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
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

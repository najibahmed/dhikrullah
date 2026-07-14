// lib/features/prayer_time/widgets/prayer_schedule_cards.dart
//
// Two dashboard cards shown below PrayerTimeCard, only during
// PrayerStatus.normal: an outlined "Next Prayer" card (name, its own
// time window, countdown until it starts) and a Sehri/Iftar card whose
// countdown/title flips between today's and tomorrow's schedule depending
// on whether today's Iftar has already passed. Countdown ticking is
// screen-local state (Timer.periodic + setState), matching PrayerTimeCard.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';

class PrayerScheduleSection extends StatefulWidget {
  const PrayerScheduleSection({super.key});

  @override
  State<PrayerScheduleSection> createState() => _PrayerScheduleSectionState();
}

class _PrayerScheduleSectionState extends State<PrayerScheduleSection> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final positive = d.isNegative ? Duration.zero : d;
    final hours = positive.inHours;
    final minutes = positive.inMinutes % 60;
    if (hours > 0) return '$hours Hour $minutes Minutes';
    return '$minutes Minutes';
  }

  String _formatClock(Duration d) {
    final positive = d.isNegative ? Duration.zero : d;
    final h = positive.inHours.toString().padLeft(2, '0');
    final m = (positive.inMinutes % 60).toString().padLeft(2, '0');
    final s = (positive.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PrayerTimeProvider>();
    if (provider.status != PrayerStatus.normal) return const SizedBox.shrink();

    final next = provider.nextPrayerPeriod;
    final sehriIftar = provider.sehriIftarInfo;
    if (next == null && sehriIftar == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          if (next != null) _nextPrayerCard(context, theme, next),
          if (next != null && sehriIftar != null) const SizedBox(height: 12),
          if (sehriIftar != null) _sehriIftarCard(context, theme, sehriIftar),
        ],
      ),
    );
  }

  Widget _nextPrayerCard(BuildContext context, ThemeData theme,
      ({String name, DateTime start, DateTime end, Duration startsIn}) next) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Prayer',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                next.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${TimeOfDay.fromDateTime(next.start).format(context)} – '
                '${TimeOfDay.fromDateTime(next.end).format(context)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          // const SizedBox(height: 6),
          // Text(
          //   'Starts in ${_formatDuration(next.startsIn)}',
          //   style: theme.textTheme.bodySmall,
          // ),
        ],
      ),
    );
  }

  Widget _sehriIftarCard(
      BuildContext context,
      ThemeData theme,
      ({
        String title,
        DateTime sehriEnd,
        DateTime iftar,
        String countdownLabel,
        Duration countdown
      }) info) {
    final fg = theme.colorScheme.onInverseSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.title,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: fg.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _scheduleRow(
                        theme, fg, 'Sehri End', info.sehriEnd, context),
                    const SizedBox(height: 8),
                    _scheduleRow(theme, fg, 'Iftar', info.iftar, context),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.countdownLabel,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: fg.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatClock(info.countdown),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow(ThemeData theme, Color fg, String label, DateTime time,
      BuildContext context) {
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
        const SizedBox(width: 12),
        Text(
          TimeOfDay.fromDateTime(time).format(context),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: fg, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

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
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/l10n/prayer_localization.dart';
import 'package:dhikir_app/core/utils/time_format.dart';

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

  String _formatDuration(BuildContext context, Duration d) {
    final l10n = context.l10n;
    final positive = d.isNegative ? Duration.zero : d;
    final hours = positive.inHours;
    final minutes = positive.inMinutes % 60;
    if (hours > 0) return l10n.durationHoursMinutes(hours, minutes);
    return l10n.durationMinutes(minutes);
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
            context.l10n.nextPrayerSection,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prayerDisplayName(context, next.name),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${formatClockTime(next.start)} – '
                '${formatClockTime(next.end)}',
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
        bool isToday,
        DateTime sehriEnd,
        DateTime iftar,
        Duration countdown
      }) info) {
    final l10n = context.l10n;
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
            info.isToday
                ? l10n.todaysScheduleTitle
                : l10n.tomorrowsScheduleTitle,
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
                        theme, fg, l10n.sehriEndLabel, info.sehriEnd, context),
                    const SizedBox(height: 8),
                    _scheduleRow(
                        theme, fg, l10n.iftarLabel, info.iftar, context),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.isToday ? l10n.iftarStartsIn : l10n.sehriEndsIn,
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
          formatClockTime(time),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: fg, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

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

import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/l10n/prayer_localization.dart';
import 'package:dhikir_app/core/utils/time_format.dart';

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
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatCountdown(BuildContext context, Duration d) {
    final l10n = context.l10n;
    final positive = d.isNegative ? Duration.zero : d;
    final hours = positive.inHours;
    final minutes = positive.inMinutes % 60;
    if (hours > 0) return l10n.countdownRemaining(hours, minutes);
    return l10n.countdownRemainingMinutes(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PrayerTimeProvider>();

    if (provider.status == PrayerStatus.normal &&
        provider.currentPrayer == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Semantics(
        button: true,
        label: _semanticLabel(context, provider),
        child: GestureDetector(
          onTap: provider.locationGranted
              ? null
              : () {
                  if (provider.permissionPermanentlyDenied) {
                    provider.openLocationSettings();
                  } else {
                    provider.init();
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: provider.status == PrayerStatus.normal
                  ? const Color.fromARGB(255, 2, 117, 106)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: ExcludeSemantics(
                child: _buildContent(context, theme, provider)),
          ),
        ),
      ),
    );
  }

  /// Screen-reader summary for the whole card, since [ExcludeSemantics]
  /// hides the individual Text/Icon children behind this single label.
  String _semanticLabel(BuildContext context, PrayerTimeProvider provider) {
    final l10n = context.l10n;
    switch (provider.status) {
      case PrayerStatus.gpsDisabled:
        return l10n.semanticsLocationDeviceOff;
      case PrayerStatus.permissionRequired:
        return l10n.semanticsLocationPermOff;
      case PrayerStatus.locationUnavailable:
        return l10n.semanticsLocationUnavailable;
      case PrayerStatus.error:
        return l10n.semanticsCalcUnavailable;
      case PrayerStatus.loading:
        return l10n.semanticsFinding;
      case PrayerStatus.forbidden:
        final period = provider.activeForbiddenPeriod;
        final next = provider.nextPrayer;
        return l10n.semanticsForbidden(
                period != null ? prayerDisplayName(context, period.name) : '') +
            (next != null
                ? l10n
                    .semanticsNextPrayer(prayerDisplayName(context, next.name))
                : '');
      case PrayerStatus.normal:
        final current = provider.currentPrayer;
        if (current == null) return l10n.semanticsPrayerTimes;
        final percent = (current.progress * 100).round();
        return l10n.semanticsCurrentPrayer(
            prayerDisplayName(context, current.name), percent);
    }
  }

  Widget _buildContent(
      BuildContext context, ThemeData theme, PrayerTimeProvider provider) {
    switch (provider.status) {
      case PrayerStatus.gpsDisabled:
        return _messageRow(
          theme,
          icon: Icons.location_disabled,
          text: context.l10n.enableLocationMessage,
        );
      case PrayerStatus.permissionRequired:
        return _messageRow(
          theme,
          icon: Icons.location_on_outlined,
          text: provider.permissionPermanentlyDenied
              ? context.l10n.locationDeniedTapSettings
              : context.l10n.enableLocationShort,
        );
      case PrayerStatus.locationUnavailable:
        return _messageRow(
          theme,
          icon: Icons.location_off_outlined,
          text: context.l10n.unableToDetermineLocation,
        );
      case PrayerStatus.error:
        return _messageRow(
          theme,
          icon: Icons.error_outline,
          text: context.l10n.unableToCalculate,
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
            Text(context.l10n.findingPrayerTimes,
                style: theme.textTheme.bodyMedium),
          ],
        );
      case PrayerStatus.forbidden:
        return _forbiddenRow(context, theme, provider);
      case PrayerStatus.normal:
        return _normalRow(context, theme, provider);
    }
  }

  Widget _messageRow(ThemeData theme,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        Icon(Icons.chevron_right,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      ],
    );
  }

  Widget _forbiddenRow(
      BuildContext context, ThemeData theme, PrayerTimeProvider provider) {
    final period = provider.activeForbiddenPeriod!;
    final next = provider.nextPrayer;
    final remaining = period.end.difference(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.error, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.block, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.forbiddenTimeLabel(
                      prayerDisplayName(context, period.name)),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.error,
                  ),
                ),
                Text(
                    context.l10n
                        .endsInLabel(_formatCountdown(context, remaining)),
                    style: theme.textTheme.bodySmall),
                if (next != null)
                  Text(
                    context.l10n.nextPrayerInline(
                        prayerDisplayName(context, next.name),
                        _formatCountdown(
                            context, next.time.difference(DateTime.now()))),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      ),
    );
  }

  Widget _normalRow(
      BuildContext context, ThemeData theme, PrayerTimeProvider provider) {
    final current = provider.currentPrayer!;
    final next = provider.nextPrayer;
    final now = DateTime.now();

    final onSecondary = theme.colorScheme.onSecondary;

    final isRamadan = HijriCalendar.fromDate(
          now.add(Duration(days: provider.hijriOffsetDays)),
        ).hMonth ==
        9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.currentPrayerSection,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: onSecondary),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.mosque_outlined, color: onSecondary),
                const SizedBox(width: 12),
                Text(
                  prayerDisplayName(context, current.name),
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: onSecondary),
                ),
              ],
            ),
            Text(
              '${formatClockTime(current.start)} – '
              '${formatClockTime(current.end)}',
              style: theme.textTheme.bodyMedium?.copyWith(color: onSecondary),
            ),
            // Icon(Icons.chevron_right,
            //     color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _formatCountdown(context, current.end.difference(now)),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: onSecondary.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current.progress,
            minHeight: 4,
            backgroundColor: onSecondary.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(onSecondary),
          ),
        ),
        // if (next != null) ...[
        //   const SizedBox(height: 10),
        //   Text(
        //     '$nextLabel ${_formatCountdown(next.time.difference(now))}',
        //     style: theme.textTheme.bodySmall,
        //   ),
        // ],
      ],
    );
  }
}

// lib/features/prayer_time/screens/prayer_time_screen.dart
//
// Single-date prayer time view: a fixed top date-nav card (prev/next day,
// tap to open a Gregorian calendar picker) above a flat list of that
// date's prayer rows (Tahajjud through Isha, with Sunrise/Sunset markers
// and an inline forbidden-time warning when applicable). Switching dates
// fades + slides the list in via AnimatedSwitcher. Notification settings
// and the Madhab/Asr calculation picker live on PrayerTimeSettingsScreen,
// reached via the AppBar's settings action.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/core/widgets/date_header_row.dart';
import 'package:dhikir_app/features/prayer_time/models/forbidden_period.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/features/prayer_time/widgets/prayer_notification_bottom_sheet.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/l10n/prayer_localization.dart';
import 'package:dhikir_app/core/utils/time_format.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _goToDate(DateTime date) {
    setState(() => _selectedDate = DateTime(date.year, date.month, date.day));
  }

  void _shiftDay(int delta) =>
      _goToDate(_selectedDate.add(Duration(days: delta)));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked != null) _goToDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerTimeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.prayerTimesTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.prayerSettingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.prayerTimeSettings),
          ),
        ],
      ),
      body: !provider.locationGranted
          ? _LocationPrompt(provider: provider)
          : Column(
              children: [
                _DateNavCard(
                  date: _selectedDate,
                  hijriOffsetDays: provider.hijriOffsetForDate(_selectedDate),
                  onPrev: () => _shiftDay(-1),
                  onNext: () => _shiftDay(1),
                  onTapDate: _pickDate,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _DatePrayerList(
                      key: ValueKey(_selectedDate),
                      date: _selectedDate,
                      provider: provider,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _LocationPrompt extends StatelessWidget {
  final PrayerTimeProvider provider;

  const _LocationPrompt({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.permissionPermanentlyDenied
                ? l10n.locationDeniedMessage
                : l10n.locationRequiredMessage,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => provider.permissionPermanentlyDenied
                ? provider.openLocationSettings()
                : provider.init(),
            child: Text(provider.permissionPermanentlyDenied
                ? l10n.openSettingsButton
                : l10n.enableLocationButton),
          ),
        ],
      ),
    );
  }
}

/// Fixed date header: prev/next day arrows either side of a tap-to-pick
/// Hijri+Gregorian date display.
class _DateNavCard extends StatelessWidget {
  final DateTime date;
  final int hijriOffsetDays;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTapDate;

  const _DateNavCard({
    required this.date,
    required this.hijriOffsetDays,
    required this.onPrev,
    required this.onNext,
    required this.onTapDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceDim,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: context.l10n.previousDayTooltip,
                icon: const Icon(Icons.chevron_left),
                onPressed: onPrev,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onTapDate,
                  child: DateHeaderRow(
                    hijriOffsetDays: hijriOffsetDays,
                    date: date,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.nextDayTooltip,
                icon: const Icon(Icons.chevron_right),
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The selected date's flat prayer-row list — Tahajjud through Isha, with
/// Sunrise/Sunset markers and an inline forbidden-time card, or a loading
/// spinner while that date's [PrayerTimes] haven't resolved yet.
class _DatePrayerList extends StatelessWidget {
  final DateTime date;
  final PrayerTimeProvider provider;

  const _DatePrayerList(
      {super.key, required this.date, required this.provider});

  @override
  Widget build(BuildContext context) {
    final times = provider.prayerTimesForDate(date);
    if (times == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final windows = provider.displayPrayerWindowsForDate(date);
    final currentName = isToday ? provider.currentPrayer?.name : null;
    final active = provider.activeForbiddenPeriodForDate(date);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        for (final w in windows) ...[
          _prayerRow(context, theme, now, w, isCurrent: w.name == currentName),
          if (w.name == 'Fajr')
            _markerRow(context, theme, context.l10n.prayerNameSunrise,
                Icons.wb_sunny_outlined, times.sunrise.toLocal()),
          if (w.name == 'Asr')
            _markerRow(context, theme, context.l10n.prayerNameSunset,
                Icons.nightlight_round, times.sunset.toLocal()),
          if (active != null &&
              !active.start.isBefore(w.start) &&
              active.start.isBefore(w.end))
            _ForbiddenWarningCard(period: active),
        ],
        _markerRow(context, theme, context.l10n.markerMiddleOfNight,
            Icons.bedtime_outlined, SunnahTimes(times).middleOfTheNight.toLocal()),
        _markerRow(
            context,
            theme,
            context.l10n.markerLastThirdOfNight,
            Icons.nightlight_outlined,
            SunnahTimes(times).lastThirdOfTheNight.toLocal()),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _prayerRow(BuildContext context, ThemeData theme, DateTime now,
      ({String name, DateTime start, DateTime end}) w,
      {required bool isCurrent}) {
    final isCompleted = !isCurrent && now.isAfter(w.end);

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

    final notifyEnabled = provider.prayerNotificationsEnabled[w.name] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isCurrent ? color : theme.dividerColor.withValues(alpha: 0.4),
            width: 1.5),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: Icon(icon, color: color),
        title: Text(
          prayerDisplayName(context, w.name),
          style: isCurrent
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${formatClockTime(w.start)} – '
          '${formatClockTime(w.end)}',
          style: theme.textTheme.labelMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: context.l10n.notificationTooltip(prayerDisplayName(context, w.name)),
              icon: Icon(
                notifyEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onPressed: () => handlePrayerBellTap(context, w.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _markerRow(BuildContext context, ThemeData theme, String label,
      IconData icon, DateTime time) {
    return ListTile(
      leading:
          Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      title: Text(label,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
      trailing: Text(
        formatClockTime(time),
        style: theme.textTheme.bodyMedium,
      ),
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
                    context.l10n.forbiddenTimeLabel(prayerDisplayName(context, period.name)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  Text(
                    context.l10n.untilTime(formatClockTime(period.end)),
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

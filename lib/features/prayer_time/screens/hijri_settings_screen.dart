// lib/features/prayer_time/screens/hijri_settings_screen.dart
//
// Dedicated Hijri date settings page: an info banner explaining why manual
// correction is sometimes needed, a live-updating day-offset adjuster, and
// a Midnight/Sunset day-rollover picker. Replaces the old inline
// _HijriOffsetSection that used to live on the prayer time detail screen.

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';

class HijriSettingsScreen extends StatelessWidget {
  const HijriSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final provider = context.watch<PrayerTimeProvider>();
    final hijri = HijriCalendar.fromDate(
      DateTime.now().add(Duration(days: provider.displayHijriOffsetDays)),
    );

    final offsetLabel = switch (provider.hijriOffsetDays) {
      0 => l10n.commonToday,
      < 0 => l10n.hijriOffsetDayLabel(provider.hijriOffsetDays),
      _ => l10n.hijriOffsetDayLabelPlus(provider.hijriOffsetDays),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hijriSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.hijriInfoBanner,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.hijriAdjustmentSection,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          provider.setHijriOffset(provider.hijriOffsetDays - 1),
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        side: BorderSide(color: theme.colorScheme.secondary),
                      ),
                      child: Icon(Icons.remove,
                          color: theme.colorScheme.secondary),
                    ),
                    Text(offsetLabel, style: theme.textTheme.bodyMedium),
                    OutlinedButton(
                      onPressed: () =>
                          provider.setHijriOffset(provider.hijriOffsetDays + 1),
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        side: BorderSide(color: theme.colorScheme.secondary),
                      ),
                      child: Icon(Icons.add, color: theme.colorScheme.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.hijriDayStartSection,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _dayStartOption(
            context,
            theme,
            provider,
            label: l10n.hijriDayStartMidnight,
            value: HijriDayStart.midnight,
          ),
          const SizedBox(height: 8),
          _dayStartOption(
            context,
            theme,
            provider,
            label: l10n.hijriDayStartSunset,
            value: HijriDayStart.sunset,
          ),
        ],
      ),
    );
  }

  Widget _dayStartOption(
    BuildContext context,
    ThemeData theme,
    PrayerTimeProvider provider, {
    required String label,
    required HijriDayStart value,
  }) {
    final selected = provider.hijriDayStart == value;
    return GestureDetector(
      onTap: () => provider.setHijriDayStart(value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.secondary.withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.secondary
                : theme.dividerColor.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            if (selected)
              CircleAvatar(
                radius: 10,
                backgroundColor: theme.colorScheme.secondary,
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

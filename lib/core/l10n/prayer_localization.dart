// lib/core/l10n/prayer_localization.dart
//
// Display-name lookup for prayer/window ids ('Fajr', 'Sunrise', ...) used
// throughout lib/features/prayer_time/**. Those ids are also Map keys,
// SharedPreferences key suffixes, and notification IDs (see
// PrayerTimeProvider.prayerLabels / optionalNotificationLabels), so they
// stay fixed English strings — only the rendered label goes through l10n.

import 'package:flutter/widgets.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

String prayerDisplayName(BuildContext context, String id) =>
    prayerDisplayNameFor(context.l10n, id);

String prayerDisplayNameFor(AppLocalizations l10n, String id) => switch (id) {
      'Fajr' => l10n.prayerNameFajr,
      'Dhuhr' => l10n.prayerNameDhuhr,
      'Asr' => l10n.prayerNameAsr,
      'Maghrib' => l10n.prayerNameMaghrib,
      'Isha' => l10n.prayerNameIsha,
      'Sunrise' => l10n.prayerNameSunrise,
      'Sunset' => l10n.prayerNameSunset,
      'Zawal' => l10n.prayerNameZawal,
      'Tahajjud' => l10n.prayerNameTahajjud,
      'Ishraq' => l10n.prayerNameIshraq,
      'Chasht' => l10n.prayerNameChasht,
      _ => id,
    };

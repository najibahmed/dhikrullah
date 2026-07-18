// lib/core/data/dhikir_localizations.dart
//
// Localized title/transliteration/meaning for the built-in dhikir set
// (lib/core/data/dhikir_data.dart), keyed by DhikirItem.id. Returns null
// for unknown ids (i.e. custom dhikir, which are user-authored Hive
// content and always render their own stored text verbatim) — callers
// fall back to the item's own field: `localizedDhikirTitle(context, id)
// ?? item.title`.

import 'package:flutter/widgets.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

String? localizedDhikirTitle(BuildContext context, String id) =>
    _title(context.l10n, id);

String? localizedDhikirTransliteration(BuildContext context, String id) =>
    _transliteration(context.l10n, id);

String? localizedDhikirMeaning(BuildContext context, String id) =>
    _meaning(context.l10n, id);

String? _title(AppLocalizations l10n, String id) => switch (id) {
      'subhanallah' => l10n.dhikirSubhanallahTitle,
      'alhamdulillah' => l10n.dhikirAlhamdulillahTitle,
      'allahuakbar' => l10n.dhikirAllahuakbarTitle,
      'lailahaillallah' => l10n.dhikirLailahaillallahTitle,
      'astaghfirullah' => l10n.dhikirAstaghfirullahTitle,
      'salawat' => l10n.dhikirSalawatTitle,
      'hasbunallah' => l10n.dhikirHasbunallahTitle,
      'lahawla' => l10n.dhikirLahawlaTitle,
      'allahumma_innaka_afuwwun' => l10n.dhikirAllahummaInnakaAfuwwunTitle,
      'la_ilaha_illallah_wahdahu' => l10n.dhikirLaIlahaIllallahWahdahuTitle,
      'subhanallahi_wa_bihamdihi' => l10n.dhikirSubhanallahiWaBihamdihiTitle,
      'subhanallahil_azeem' => l10n.dhikirSubhanallahilAzeemTitle,
      'sayyidul_istighfar_extended' =>
        l10n.dhikirSayyidulIstighfarExtendedTitle,
      'salawat_on_nabi' => l10n.dhikirSalawatOnNabiTitle,
      _ => null,
    };

String? _transliteration(AppLocalizations l10n, String id) => switch (id) {
      'subhanallah' => l10n.dhikirSubhanallahTransliteration,
      'alhamdulillah' => l10n.dhikirAlhamdulillahTransliteration,
      'allahuakbar' => l10n.dhikirAllahuakbarTransliteration,
      'lailahaillallah' => l10n.dhikirLailahaillallahTransliteration,
      'astaghfirullah' => l10n.dhikirAstaghfirullahTransliteration,
      'salawat' => l10n.dhikirSalawatTransliteration,
      'hasbunallah' => l10n.dhikirHasbunallahTransliteration,
      'lahawla' => l10n.dhikirLahawlaTransliteration,
      'allahumma_innaka_afuwwun' =>
        l10n.dhikirAllahummaInnakaAfuwwunTransliteration,
      'la_ilaha_illallah_wahdahu' =>
        l10n.dhikirLaIlahaIllallahWahdahuTransliteration,
      'subhanallahi_wa_bihamdihi' =>
        l10n.dhikirSubhanallahiWaBihamdihiTransliteration,
      'subhanallahil_azeem' => l10n.dhikirSubhanallahilAzeemTransliteration,
      'sayyidul_istighfar_extended' =>
        l10n.dhikirSayyidulIstighfarExtendedTransliteration,
      'salawat_on_nabi' => l10n.dhikirSalawatOnNabiTransliteration,
      _ => null,
    };

String? _meaning(AppLocalizations l10n, String id) => switch (id) {
      'subhanallah' => l10n.dhikirSubhanallahMeaning,
      'alhamdulillah' => l10n.dhikirAlhamdulillahMeaning,
      'allahuakbar' => l10n.dhikirAllahuakbarMeaning,
      'lailahaillallah' => l10n.dhikirLailahaillallahMeaning,
      'astaghfirullah' => l10n.dhikirAstaghfirullahMeaning,
      'salawat' => l10n.dhikirSalawatMeaning,
      'hasbunallah' => l10n.dhikirHasbunallahMeaning,
      'lahawla' => l10n.dhikirLahawlaMeaning,
      'allahumma_innaka_afuwwun' => l10n.dhikirAllahummaInnakaAfuwwunMeaning,
      'la_ilaha_illallah_wahdahu' =>
        l10n.dhikirLaIlahaIllallahWahdahuMeaning,
      'subhanallahi_wa_bihamdihi' =>
        l10n.dhikirSubhanallahiWaBihamdihiMeaning,
      'subhanallahil_azeem' => l10n.dhikirSubhanallahilAzeemMeaning,
      'sayyidul_istighfar_extended' =>
        l10n.dhikirSayyidulIstighfarExtendedMeaning,
      'salawat_on_nabi' => l10n.dhikirSalawatOnNabiMeaning,
      _ => null,
    };

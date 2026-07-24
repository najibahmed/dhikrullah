// lib/features/about/screens/about_screen.dart
//
// Static app-info page. Version is hardcoded to match pubspec.yaml's
// `version:` field rather than pulling in package_info_plus for one
// static string. Developer fields are placeholders — fill in before
// shipping.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/providers/locale_provider.dart';
import 'package:dhikir_app/core/providers/theme_provider.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

const _appVersion = '1.0.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = context.watch<LocaleProvider>().locale;
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.aboutAppName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(l10n.aboutVersion(_appVersion), style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(l10n.aboutDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          Text(l10n.settingsLanguage,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_languageLabel(l10n, locale)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context),
          ),
          const SizedBox(height: 32),
          Text(l10n.themeSettingsRowLabel,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_themeLabel(l10n, themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context),
          ),
          const SizedBox(height: 32),
          Text(l10n.aboutDeveloper,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(l10n.aboutDeveloperNamePlaceholder, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(l10n.aboutBioPlaceholder, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(l10n.aboutContactPlaceholder, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, Locale? locale) {
    switch (locale?.languageCode) {
      case 'bn':
        return l10n.settingsLanguageBangla;
      case 'en':
        return l10n.settingsLanguageEnglish;
      default:
        return l10n.settingsLanguageSystem;
    }
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeSettingsLight;
      case ThemeMode.dark:
        return l10n.themeSettingsDark;
      case ThemeMode.system:
        return l10n.themeSettingsSystem;
    }
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final l10n = context.l10n;
    final themeProvider = context.read<ThemeProvider>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.themeSettingsDialogTitle),
        children: [
          SimpleDialogOption(
            onPressed: () {
              themeProvider.setTheme(ThemeMode.system);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.themeSettingsSystem),
          ),
          SimpleDialogOption(
            onPressed: () {
              themeProvider.setTheme(ThemeMode.light);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.themeSettingsLight),
          ),
          SimpleDialogOption(
            onPressed: () {
              themeProvider.setTheme(ThemeMode.dark);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.themeSettingsDark),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final l10n = context.l10n;
    final localeProvider = context.read<LocaleProvider>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsLanguageDialogTitle),
        children: [
          SimpleDialogOption(
            onPressed: () {
              localeProvider.setLocale(null);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.settingsLanguageSystem),
          ),
          SimpleDialogOption(
            onPressed: () {
              localeProvider.setLocale(const Locale('en'));
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.settingsLanguageEnglish),
          ),
          SimpleDialogOption(
            onPressed: () {
              localeProvider.setLocale(const Locale('bn'));
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.settingsLanguageBangla),
          ),
        ],
      ),
    );
  }
}

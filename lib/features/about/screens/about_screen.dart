// lib/features/about/screens/about_screen.dart
//
// Static app-info page. Version is hardcoded to match pubspec.yaml's
// `version:` field rather than pulling in package_info_plus for one
// static string. Developer fields are placeholders — fill in before
// shipping.

import 'package:flutter/material.dart';

const _appVersion = '1.0.0';
const _appDescription = 'A daily dhikir tracker app with 30-day tracking';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Daily Dhikir', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Version $_appVersion', style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(_appDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          Text('Developer', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Developer name — TODO', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Short bio — TODO', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Contact — TODO', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

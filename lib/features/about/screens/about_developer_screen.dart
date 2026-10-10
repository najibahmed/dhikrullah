// lib/features/about/screens/about_developer_screen.dart
//
// Static developer profile with contact tiles (email, WhatsApp, website).

import 'package:flutter/material.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/features/about/app_links.dart';
import 'package:dhikir_app/features/about/support_actions.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutDeveloperTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                'NA',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aboutDeveloperName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.aboutDeveloperRole,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aboutDeveloperBio,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: Text(l10n.aboutDeveloperEmail),
            subtitle: const Text(AppLinks.developerEmail),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => openDeveloperEmail(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.chat_outlined),
            title: Text(l10n.feedbackTitle),
            subtitle: const Text(AppLinks.smsNumber),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => openFeedbackChat(context),
          ),
          if (AppLinks.developerWebsite.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.public),
              title: Text(l10n.aboutDeveloperWebsite),
              subtitle: const Text(AppLinks.developerWebsite),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => openDeveloperWebsite(context),
            ),
        ],
      ),
    );
  }
}

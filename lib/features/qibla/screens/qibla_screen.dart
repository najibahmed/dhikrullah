// lib/features/qibla/screens/qibla_screen.dart
//
// Placeholder for the Qibla compass feature. No compass logic yet —
// exists so the Quick Actions tile has a real, navigable destination.

import 'package:flutter/material.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qiblaTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.qiblaComingSoon, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

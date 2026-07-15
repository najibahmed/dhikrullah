// lib/features/qibla/screens/qibla_screen.dart
//
// Placeholder for the Qibla compass feature. No compass logic yet —
// exists so the Quick Actions tile has a real, navigable destination.

import 'package:flutter/material.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Compass')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Coming soon', style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

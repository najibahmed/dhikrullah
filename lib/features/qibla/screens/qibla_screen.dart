// lib/features/qibla/screens/qibla_screen.dart
//
// Qibla compass. Rotates a dial by the device heading (flutter_compass)
// and marks the bearing to the Kaaba, computed from the same coordinates
// the prayer-time feature already caches — no new GPS/permission logic.

import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/features/prayer_time/services/location_service.dart';
import 'package:dhikir_app/features/qibla/services/qibla_calculator.dart';

enum _LocationState { loading, denied, ready }

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  _LocationState _state = _LocationState.loading;
  double? _bearing;

  // Cumulative dial rotation in turns, so AnimatedRotation takes the short
  // way across the 359°→0° wrap instead of spinning a full circle back.
  double _dialTurns = 0;
  double _lastHeading = 0;

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  Future<void> _resolveLocation() async {
    setState(() => _state = _LocationState.loading);

    Coordinates? coords = context.read<PrayerTimeProvider>().coordinates;
    coords ??= await LocationService.getCachedCoordinates();
    if (coords == null) {
      try {
        if (await LocationService.checkAndRequestPermission()) {
          coords = await LocationService.getCurrentCoordinates();
        }
      } catch (_) {
        coords = null;
      }
    }

    if (!mounted) return;
    setState(() {
      if (coords == null) {
        _state = _LocationState.denied;
      } else {
        _bearing = QiblaCalculator.bearing(coords.latitude, coords.longitude);
        _state = _LocationState.ready;
      }
    });
  }

  double _turnsFor(double heading) {
    var delta = heading - _lastHeading;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    _lastHeading = heading;
    _dialTurns -= delta / 360;
    return _dialTurns;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qiblaTitle)),
      body: switch (_state) {
        _LocationState.loading =>
          const Center(child: CircularProgressIndicator()),
        _LocationState.denied => _DeniedView(onRetry: _resolveLocation),
        _LocationState.ready => _buildCompass(context),
      },
    );
  }

  Widget _buildCompass(BuildContext context) {
    final stream = FlutterCompass.events;
    if (stream == null) return const _NoSensorView();

    return StreamBuilder<CompassEvent>(
      stream: stream,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading;
        if (heading == null) {
          return snapshot.hasData
              ? const _NoSensorView()
              : const Center(child: CircularProgressIndicator());
        }
        return _CompassView(
          heading: heading,
          bearing: _bearing!,
          dialTurns: _turnsFor(heading),
        );
      },
    );
  }
}

class _CompassView extends StatelessWidget {
  const _CompassView({
    required this.heading,
    required this.bearing,
    required this.dialTurns,
  });

  final double heading;
  final double bearing;
  final double dialTurns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final diff = QiblaCalculator.difference(heading, bearing);
    final aligned = diff.abs() <= 5;
    final statusText = aligned
        ? l10n.qiblaFacing
        : (diff < 0 ? l10n.qiblaTurnLeft : l10n.qiblaTurnRight);
    final accent =
        aligned ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            statusText,
            style: theme.textTheme.titleLarge?.copyWith(
              color: aligned ? theme.colorScheme.primary : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Icon(Icons.arrow_drop_down, size: 36, color: accent),
          AnimatedRotation(
            turns: dialTurns,
            duration: const Duration(milliseconds: 250),
            child: _Dial(bearing: bearing, aligned: aligned),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoTile(
                label: l10n.qiblaHeadingLabel,
                value: '${heading.round()}°',
              ),
              const SizedBox(width: 40),
              _InfoTile(
                label: l10n.qiblaBearingLabel,
                value: '${bearing.round()}°',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({required this.bearing, required this.aligned});

  final double bearing;
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.titleMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: aligned
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: 2,
        ),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final (angle, label) in [
            (0, 'N'),
            (90, 'E'),
            (180, 'S'),
            (270, 'W')
          ])
            Transform.rotate(
              angle: angle * math.pi / 180,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(label, style: labelStyle),
                ),
              ),
            ),
          Transform.rotate(
            angle: bearing * math.pi / 180,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Image.asset(
                    'assets/images/kibla_arrow.png',
                    width: 62,
                    height: 62,
                  )),
            ),
          ),
          Icon(
            Icons.circle,
            size: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _DeniedView extends StatelessWidget {
  const _DeniedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.locationDeniedMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: LocationService.openAppSettings,
              child: Text(l10n.openSettingsButton),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSensorView extends StatelessWidget {
  const _NoSensorView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_outlined,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.qiblaNoSensor,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

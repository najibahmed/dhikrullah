// lib/features/prayer_time/widgets/digital_clock.dart
//
// Live 12-hour clock shown above the current prayer card on home. Rebuilds
// once per minute via a one-shot Timer aligned to the next minute boundary,
// and re-syncs on app resume (timers drift/pause while backgrounded).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/utils/time_format.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextTick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _scheduleNextTick();
    }
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleNextTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Semantics(
        label: formatClockTime(now),
        excludeSemantics: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatClockHourMinute(now),
              style: GoogleFonts.orbitron(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                // fontStyle: FontStyle.italic,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              formatClockPeriod(now),
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

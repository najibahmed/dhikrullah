// lib/core/theme/theme_colors.dart
//
// Brand/data-color helpers that must NOT become plain colorScheme swaps:
// the mint accent (repeats across 5+ screens) and per-dhikir/per-category
// data colors, which need a dark-mode-safe variant that keeps their hue
// identity rather than a generic structural color.

import 'package:flutter/material.dart';

/// Mint accent background used by Qibla/Tasbih quick-actions, Dua/Allah
/// Names accents, and the font-size dialog's slider track.
Color mintAccentBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F332A) : const Color(0xFFE8F5E9);
}

/// Border paired with [mintAccentBackground].
Color mintAccentBorder(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2F5443) : const Color(0xFFC6E6C8);
}

/// Current-prayer card background on Home/PrayerTimeCard.
Color currentPrayerCardBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF15A190) : const Color.fromARGB(255, 2, 117, 106);
}

/// Adjusts a stored per-dhikir/category data color for dark-mode surfaces.
/// Most stored colors are light pastels chosen against a light background;
/// on a dark background they become a "muted tonal" version: same hue (so
/// each dhikir still reads as "its own color"), fixed deep lightness, and
/// capped saturation. Pastels like #FFF8E1 are ~100% saturated in HSL, so
/// keeping or boosting saturation turns them neon at low lightness.
Color adjustForBrightness(Color base, Brightness brightness) {
  if (brightness == Brightness.light) return base;
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness(0.22).withSaturation(hsl.saturation.clamp(0.0, 0.30)).toColor();
}

/// Picks a legible text/icon color to sit on top of [background], based on
/// the background's actual (possibly dark-adjusted) luminance rather than a
/// fixed light/dark literal.
Color onColorFor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark ? Colors.white : const Color(0xFF2D3748);
}

/// Like [adjustForBrightness], but for a stored color used as a *highlight*
/// drawn on a dark surface (progress ring, milestone dots) rather than as a
/// background. In dark mode the muted tonal background would barely differ
/// from the surface, so this returns a soft pastel of the same hue instead.
Color accentForBrightness(Color base, Brightness brightness) {
  if (brightness == Brightness.light) return base;
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness(0.60).withSaturation(hsl.saturation.clamp(0.0, 0.45)).toColor();
}

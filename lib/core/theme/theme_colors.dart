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
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1F332A)
      : const Color(0xFFE8F5E9);
}

/// Border paired with [mintAccentBackground].
Color mintAccentBorder(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF2F5443)
      : const Color(0xFFC6E6C8);
}

/// Adjusts a stored per-dhikir/category data color for dark-mode surfaces.
/// Most stored colors are light pastels chosen against a light background;
/// on a dark background they need reduced lightness (so they don't glow)
/// and a slight saturation boost (so they don't wash out), while keeping
/// the same hue so each dhikir still reads as "its own color".
Color adjustForBrightness(Color base, Brightness brightness) {
  if (brightness == Brightness.light) return base;
  final hsl = HSLColor.fromColor(base);
  final adjustedLightness = hsl.lightness > 0.35 ? 0.30 : hsl.lightness.clamp(0.25, 0.35);
  return hsl
      .withLightness(adjustedLightness)
      .withSaturation((hsl.saturation * 1.15).clamp(0.0, 1.0))
      .toColor();
}

/// Picks a legible text/icon color to sit on top of [background], based on
/// the background's actual (possibly dark-adjusted) luminance rather than a
/// fixed light/dark literal.
Color onColorFor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : const Color(0xFF2D3748);
}

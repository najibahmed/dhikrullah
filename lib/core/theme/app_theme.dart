// lib/core/theme/app_theme.dart
//
// Light/dark ThemeData definitions. Screens still largely use AppColors/
// hardcoded hex literals rather than Theme.of(context); that migration is
// tracked as an ongoing, screen-by-screen effort (see .claude/specs/
// refactor.md §6), not part of this file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Dark palette tokens ──────────────────────────────────────────────────
// Distinct surface levels so cards/dialogs actually lift off the scaffold
// background instead of blending into one flat tone.
const _darkBg = Color(0xFF1A202C);
const _darkSurface = Color(0xFF222A38);
const _darkSurfaceHi = Color(0xFF2D3748);
const _darkBorder = Color(0xFF3A4453);
const _darkTextPrimary = Color(0xFFEDF2F7);
const _darkTextSecondary = Color(0xFFA0AEC0);
const _darkTextMuted = Color(0xFF718096);

// ─── Light palette tokens ─────────────────────────────────────────────────
const _lightBg = Color(0xFFF6F4F1);
const _lightSurface = Colors.white;
const _lightBorder = Color(0xFFE2E8F0);
const _lightTextPrimary = Color(0xFF2D3748);
const _lightTextSecondary = Color(0xFF718096);

const _cardRadius = 20.0;
const _dialogRadius = 24.0;

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4A5568),
      brightness: Brightness.light,
      surface: _lightSurface,
    ),
    scaffoldBackgroundColor: _lightBg,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBg,
      foregroundColor: _lightTextPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: _lightTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_dialogRadius)),
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _lightTextPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: _lightTextSecondary),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: _lightTextPrimary,
      iconColor: _lightTextSecondary,
    ),
    dividerTheme: const DividerThemeData(color: _lightBorder, thickness: 1),
    iconTheme: const IconThemeData(color: _lightTextPrimary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: GoogleFonts.inter(color: _lightTextSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2D3748),
      unselectedItemColor: Color(0xFFA0AEC0),
      elevation: 8,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4A5568),
      brightness: Brightness.dark,
      surface: _darkSurface,
    ),
    scaffoldBackgroundColor: _darkBg,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: _darkTextPrimary,
      displayColor: _darkTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBg,
      foregroundColor: _darkTextPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: _darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurfaceHi,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_dialogRadius)),
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _darkTextPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: _darkTextSecondary),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: _darkTextPrimary,
      iconColor: _darkTextSecondary,
    ),
    dividerTheme: const DividerThemeData(color: _darkBorder, thickness: 1),
    iconTheme: const IconThemeData(color: _darkTextPrimary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: GoogleFonts.inter(color: _darkTextMuted),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2D3748),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFF718096),
      elevation: 8,
    ),
  );
}

// lib/core/theme/app_theme.dart
//
// Light/dark ThemeData definitions, extracted from main.dart. Pure move —
// no color/behavior changes. Screens still largely use AppColors/hardcoded
// hex literals rather than Theme.of(context); that migration is tracked as
// an ongoing, screen-by-screen effort (see .claude/specs/refactor.md §6),
// not part of this extraction.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4A5568),
      brightness: Brightness.light,
      surface: const Color(0xFFF6F4F1),
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F4F1),
    textTheme: GoogleFonts.interTextTheme(),
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
      surface: const Color(0xFF1A202C),
    ),
    scaffoldBackgroundColor: const Color(0xFF1A202C),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2D3748),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFF718096),
      elevation: 8,
    ),
  );
}

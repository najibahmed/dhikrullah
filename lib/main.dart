// lib/main.dart
//
// App entry point.
// Initialises storage layers first, then wraps the widget tree with
// MultiProvider so every screen can access ThemeProvider and
// FavoritesProvider via context.

import 'package:dhikir_app/features/dhikir/providers/dhikir_calendar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/providers/theme_provider.dart';
import 'package:dhikir_app/core/providers/favorites_provider.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/features/dhikir/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar with dark icons.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Storage must be ready before providers read from it.
  await HiveService.init();
  await CustomDhikirService.init();

  // Load persisted theme before first paint to avoid flash.
  final themeProvider = await ThemeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const DhikirApp(),
    ),
  );
}

class DhikirApp extends StatelessWidget {
  const DhikirApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Daily Dhikir',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // ── Light theme ─────────────────────────────────────────────────────────
      theme: ThemeData(
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
      ),

      // ── Dark theme ──────────────────────────────────────────────────────────
      darkTheme: ThemeData(
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
      ),

      home: const HomeScreen(),
      onGenerateRoute: AppRoutes.generate,
    );
  }
}

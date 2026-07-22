// lib/main.dart
//
// App entry point.
// Initialises storage layers first, then wraps the widget tree with
// MultiProvider so every screen can access ThemeProvider and
// FavoritesProvider via context.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/providers/theme_provider.dart';
import 'package:dhikir_app/core/providers/locale_provider.dart';
import 'package:dhikir_app/core/providers/favorites_provider.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/core/theme/app_theme.dart';
import 'package:dhikir_app/features/dhikir/screens/home_screen.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale-aware month/weekday name formatting (DateFormat) needs its
  // symbol data loaded before first use.
  await initializeDateFormatting();

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

  // Load persisted theme + locale before first paint to avoid flash.
  final themeProvider = await ThemeProvider.load();
  final localeProvider = await LocaleProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimeProvider()),
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
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Dhikrullah',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
      onGenerateRoute: AppRoutes.generate,
    );
  }
}

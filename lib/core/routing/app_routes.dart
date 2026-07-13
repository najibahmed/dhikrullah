// lib/core/routing/app_routes.dart
//
// onGenerateRoute table + typed arguments classes for every named route.
// Arguments are passed as Dart objects via RouteSettings.arguments rather
// than raw Maps, so each route's required data is compile-time checked
// at the call site.

import 'package:flutter/material.dart';

import 'package:dhikir_app/core/models/custom_dhikir_model.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/features/my_dhikir/screens/add_dhikir_screen.dart';
import 'package:dhikir_app/features/analytics/screens/analytics_screen.dart';
import 'package:dhikir_app/features/dhikir/screens/dhikir_calendar_screen.dart';
import 'package:dhikir_app/features/dhikir/screens/dhikir_detail_screen.dart';
import 'package:dhikir_app/features/my_dhikir/screens/my_dhikir_screen.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';
import 'package:dhikir_app/features/prayer_time/screens/prayer_time_screen.dart';
import 'route_names.dart';

class SessionCounterArgs {
  final List<SessionDhikir> dhikirList;
  final int initialIndex;
  final int sharedGoal;

  const SessionCounterArgs({
    required this.dhikirList,
    this.initialIndex = 0,
    required this.sharedGoal,
  });
}

class DhikirDetailArgs {
  final DhikirItem dhikir;
  const DhikirDetailArgs({required this.dhikir});
}

class DhikirCalendarArgs {
  final DhikirItem dhikir;
  const DhikirCalendarArgs({required this.dhikir});
}

class AddDhikirArgs {
  final CustomDhikirItem? existing;
  const AddDhikirArgs({this.existing});
}

class AppRoutes {
  AppRoutes._();

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.sessionCounter:
        final args = settings.arguments as SessionCounterArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SessionCounterScreen(
            dhikirList: args.dhikirList,
            initialIndex: args.initialIndex,
            sharedGoal: args.sharedGoal,
          ),
        );

      case RouteNames.myDhikir:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyDhikirScreen(),
        );

      case RouteNames.analytics:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AnalyticsScreen(),
        );

      case RouteNames.dhikirDetail:
        final args = settings.arguments as DhikirDetailArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DhikirDetailScreen(dhikir: args.dhikir),
        );

      case RouteNames.dhikirCalendar:
        final args = settings.arguments as DhikirCalendarArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DhikirCalendarScreen(dhikir: args.dhikir),
        );

      case RouteNames.addDhikir:
        final args = settings.arguments as AddDhikirArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddDhikirScreen(existing: args?.existing),
        );

      case RouteNames.prayerTime:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrayerTimeScreen(),
        );

      default:
        throw FlutterError('Unknown route: ${settings.name}');
    }
  }
}

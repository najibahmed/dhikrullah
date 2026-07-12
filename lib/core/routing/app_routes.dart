// lib/core/routing/app_routes.dart
//
// onGenerateRoute table + typed arguments classes for every named route.
// Arguments are passed as Dart objects via RouteSettings.arguments rather
// than raw Maps, so each route's required data is compile-time checked
// at the call site.

import 'package:flutter/material.dart';

import '../../models/custom_dhikir_model.dart';
import '../../models/dhikir_model.dart';
import '../../screens/add_dhikir_screen.dart';
import '../../screens/analytics_screen.dart';
import '../../screens/dhikir_calendar_screen.dart';
import '../../screens/dhikir_detail_screen.dart';
import '../../screens/my_dhikir_screen.dart';
import '../../screens/session_counter_screen.dart';
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

      default:
        throw FlutterError('Unknown route: ${settings.name}');
    }
  }
}

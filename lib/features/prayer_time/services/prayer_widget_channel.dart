// lib/features/prayer_time/services/prayer_widget_channel.dart
//
// Dart side of the dhikir_app/widget MethodChannel — thin wrapper over the
// Kotlin PrayerWidgetMethodChannel (home-screen prayer widget). No logic
// beyond marshalling; what data the widget shows is PrayerWidgetService's job.

import 'package:flutter/services.dart';

class PrayerWidgetChannel {
  static const _channel = MethodChannel('dhikir_app/widget');

  /// Re-render every placed widget from the persisted JSON.
  static Future<void> refresh() => _channel.invokeMethod('refresh');

  /// Route requested by a widget tap that cold-started the app, or null.
  /// Cleared on read so it's handled once.
  static Future<String?> consumeLaunchRoute() => _channel.invokeMethod<String>('consumeLaunchRoute');

  static Future<bool> isPinSupported() async => await _channel.invokeMethod<bool>('isPinSupported') ?? false;

  /// Asks the launcher to show its "add widget" dialog. False if unsupported.
  static Future<bool> requestPin() async => await _channel.invokeMethod<bool>('requestPin') ?? false;

  /// Widget tapped while the app was already running.
  static void listenOpenRoute(void Function(String route) onRoute) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openRoute' && call.arguments is String) {
        onRoute(call.arguments as String);
      }
    });
  }
}

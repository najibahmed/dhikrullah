// lib/features/qibla/services/qibla_calculator.dart
//
// Pure math: great-circle initial bearing from a location to the Kaaba,
// plus the signed shortest-turn difference used for left/right guidance.

import 'dart:math' as math;

class QiblaCalculator {
  QiblaCalculator._();

  static const double _kaabaLat = 21.422487;
  static const double _kaabaLng = 39.826206;

  /// Initial great-circle bearing from ([lat], [lng]) to the Kaaba,
  /// normalized to 0–360° clockwise from true north.
  static double bearing(double lat, double lng) {
    final phi1 = _rad(lat);
    final phi2 = _rad(_kaabaLat);
    final deltaLng = _rad(_kaabaLng - lng);
    final y = math.sin(deltaLng) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLng);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  /// Signed shortest difference from [heading] to [bearing] in −180..180.
  /// Negative means turn left, positive means turn right.
  static double difference(double heading, double bearing) =>
      (bearing - heading + 540) % 360 - 180;

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}

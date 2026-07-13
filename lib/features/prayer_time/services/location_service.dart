// lib/features/prayer_time/services/location_service.dart
//
// Wraps geolocator permission handling + position lookup, and caches the
// last-known coordinates in SharedPreferences so the UI has something to
// show instantly on relaunch while a fresh GPS fix is acquired.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLastLatKey = 'prayer_last_lat';
const _kLastLngKey = 'prayer_last_lng';

class LocationService {
  LocationService._();

  /// Whether the device's location service (GPS) is turned on at all,
  /// independent of whether this app has permission to use it.
  static Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// Requests location permission if not already granted.
  /// Returns true only when permission is granted (while-in-use or always).
  static Future<bool> checkAndRequestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Fetches a fresh GPS fix and persists it as the last-known location.
  static Future<Coordinates> getCurrentCoordinates() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    await _cacheCoordinates(position.latitude, position.longitude);
    return Coordinates(position.latitude, position.longitude);
  }

  /// Returns the last cached coordinates (if any) without touching GPS.
  static Future<Coordinates?> getCachedCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_kLastLatKey);
    final lng = prefs.getDouble(_kLastLngKey);
    if (lat == null || lng == null) return null;
    return Coordinates(lat, lng);
  }

  static Future<void> _cacheCoordinates(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLastLatKey, lat);
    await prefs.setDouble(_kLastLngKey, lng);
  }
}

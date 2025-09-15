import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  static Position? _cachedPosition;
  static DateTime? _lastFetchedAt;

  static const Duration _cacheDuration = Duration(minutes: 2);

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> isLocationPermissionGranted(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show a dialog or snackbar to inform the user about denied permissions
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("Location permission is required")),
          );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, so navigate the user to app settings
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
              content: Text("Location permissions are permanently denied")),
        );
      return false;
    }

    return true; // Permissions granted
  }

  static Future<Position?> determinePosition() async {
    // Проверяем кэш
    if (_cachedPosition != null && _lastFetchedAt != null) {
      final difference = DateTime.now().difference(_lastFetchedAt!);
      if (difference < _cacheDuration) {
        return _cachedPosition;
      }
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return await Geolocator.getLastKnownPosition();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return await Geolocator.getLastKnownPosition();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return await Geolocator.getLastKnownPosition();
    }

    // Получаем свежую позицию
    final currentPosition = await Geolocator.getCurrentPosition();

    // Сохраняем в кэш
    _cachedPosition = currentPosition;
    _lastFetchedAt = DateTime.now();

    return currentPosition;
  }
}

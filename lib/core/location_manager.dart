import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  static Position? _cachedPosition;
  static DateTime? _lastFetchedAt;

  static const Duration _cacheDuration = Duration(minutes: 2);
  static const Duration _defaultTimeout = Duration(seconds: 8);

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> isLocationPermissionGranted(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show a dialog or snackbar to inform the user about denied permissions
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Для работы карты нужен доступ к геолокации')),
            );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Доступ к геолокации отключён в настройках телефона'),
            ),
          );
      }
      return false;
    }

    return true; // Permissions granted
  }

  /// [requestIfDenied] — false при загрузке из bottom sheet, чтобы не показывать
  /// системный диалог разрешений под шторкой (иначе запрос может «зависнуть»).
  static Future<Position?> determinePosition({
    bool requestIfDenied = true,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      if (_cachedPosition != null && _lastFetchedAt != null) {
        final difference = DateTime.now().difference(_lastFetchedAt!);
        if (difference < _cacheDuration) {
          return _cachedPosition;
        }
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await Geolocator.getLastKnownPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestIfDenied) {
        permission = await Geolocator.requestPermission().timeout(
          timeout,
          onTimeout: () => LocationPermission.denied,
        );
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return await Geolocator.getLastKnownPosition();
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: timeout,
        ),
      ).timeout(timeout);

      _cachedPosition = currentPosition;
      _lastFetchedAt = DateTime.now();

      return currentPosition;
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }
}

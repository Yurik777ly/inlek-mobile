import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> isLocationPermissionGranted(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show a dialog or snackbar to inform the user about denied permissions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required")),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, so navigate the user to app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied")),
      );
      return false;
    }

    return true; // Permissions granted
  }

  Future<Position?> determinePosition() async {
    return Position(
        longitude: 29.20812652970049,
        latitude: 53.1689884118156,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        altitudeAccuracy: 1,
        heading: 1,
        headingAccuracy: 1,
        speed: 1,
        speedAccuracy: 1);
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

    return await Geolocator.getCurrentPosition();
  }
}

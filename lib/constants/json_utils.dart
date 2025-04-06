import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/core/models/courier_zone_model.dart';

class JsonUtils {
  // Загружаем зоны доставки из JSON
  static Future<CourierZoneModel> loadCourierZones() async {
    String jsonString = await rootBundle.loadString(Paths.courierZonesJsonPath);
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return CourierZoneModel.fromJson(jsonData);
  }
}

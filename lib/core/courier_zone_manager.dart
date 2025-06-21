import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart' as yg;
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'models/courier_zone_model.dart'; // путь к твоей модели

class CourierZoneManager {
  late final CourierZoneModel _courierZoneData;
  late final List<CustomMapObject> _mapObjects;

  CourierZoneModel get courierZoneData => _courierZoneData;
  List<CustomMapObject> get mapObjects => _mapObjects;

  /// Инициализация: загрузка и парсинг JSON и создание объектов
  Future<void> init() async {
    final jsonString = await rootBundle.loadString(Paths.courierZonesJsonPath);
    final jsonData = jsonDecode(jsonString);
    _courierZoneData = CourierZoneModel.fromJson(jsonData);

    _mapObjects = _loadPolygonObjects();
  }

  /// Метод для загрузки объектов на карту
  List<CustomMapObject> _loadPolygonObjects() {
    List<CustomMapObject> mapObjects = [];

    for (Feature feature in _courierZoneData.features) {
      for (List<List<double>> coordinates in feature.geometry.coordinates) {
        mapObjects.add(
          CustomMapObject(
            mapObject: PolygonMapObject(
              fillColor: Color(
                int.parse(
                  "0xFF${feature.properties.fill.replaceAll('#', '')}",
                ),
              ).withOpacity(feature.properties.fillOpacity),
              strokeColor: Color(
                int.parse(
                  "0xFF${feature.properties.stroke.replaceAll('#', '')}",
                ),
              ).withOpacity(feature.properties.strokeOpacity),
              strokeWidth: feature.properties.strokeWidth,
              mapId: MapObjectId(feature.id.toString()),
              polygon: Polygon(
                outerRing: LinearRing(
                  points: List.generate(
                    coordinates.length,
                    (index) => Point(
                      latitude: coordinates[index].last,
                      longitude: coordinates[index].first,
                    ),
                  ),
                ),
                innerRings: [],
              ),
            ),
          ),
        );
      }
    }

    return mapObjects;
  }

  /// Метод для получения типа зоны по координатам
  DeliveryZoneType getZoneTypeByCoordinates(yg.Point? point) {
    if (point == null) return DeliveryZoneType.none;
    for (final feature in _courierZoneData.features) {
      for (final ring in feature.geometry.coordinates) {
        final polygon = ring
            .map((coord) => Point(
                  latitude: coord[1],
                  longitude: coord[0],
                ))
            .toList();

        if (_pointInPolygon(point, polygon)) {
          final color = feature.properties.fill.toLowerCase();

          if (['#00ff00', '#4caf50', '#56db40'].contains(color)) {
            return DeliveryZoneType.green;
          } else if (['#ffd21e', '#ffff00', '#ffeb3b'].contains(color)) {
            return DeliveryZoneType.yellow;
          } else {
            return DeliveryZoneType.none;
          }
        }
      }
    }
    return DeliveryZoneType.none;
  }

  /// Проверка принадлежности точки полигону
  bool _pointInPolygon(yg.Point point, List<Point> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      final p1 = polygon[j];
      final p2 = polygon[j + 1];

      if (_rayCastIntersect(point, p1, p2)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  /// Вспомогательная функция для _pointInPolygon
  bool _rayCastIntersect(yg.Point point, Point vertA, Point vertB) {
    final double lat = point.latitude ?? 0;
    final double lng = point.longitude ?? 0;
    final double latA = vertA.latitude;
    final double lngA = vertA.longitude;
    final double latB = vertB.latitude;
    final double lngB = vertB.longitude;

    if ((lngA > lng) == (lngB > lng)) return false;

    final intersectionLat = (latB - latA) * (lng - lngA) / (lngB - lngA) + latA;
    return lat < intersectionLat;
  }
}

import 'package:inlek/features/domain/entities/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.pagetitle,
    required super.alias,
    required super.published,
    required super.latitude,
    required super.longitude,
    required super.isDeliveryAvailable,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json['id'] as int,
        pagetitle: json['pagetitle']?.toString() ?? '',
        alias: json['alias']?.toString() ?? '',
        published: json['published'] == 1 || json['published'] == true,
        latitude: _parseCoordinate(json['latitude']),
        longitude: _parseCoordinate(json['longitude']),
        isDeliveryAvailable: json['is_delivery_available'] == true ||
            json['is_delivery_available'] == 1,
      );

  static double _parseCoordinate(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pagetitle': pagetitle,
        'alias': alias,
        'published': published ? 1 : 0,
        'latitude': latitude,
        'longitude': longitude,
        'is_delivery_available': isDeliveryAvailable ? 1 : 0,
      };
}

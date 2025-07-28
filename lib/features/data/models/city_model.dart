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
        id: json['id'],
        pagetitle: json['pagetitle'],
        alias: json['alias'],
        published: json['published'] == 1,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isDeliveryAvailable: json['is_delivery_available'] == true ||
            json['is_delivery_available'] == 1,
      );

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

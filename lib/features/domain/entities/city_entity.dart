import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final int id;
  final String pagetitle;
  final String alias;
  final bool published;
  final double latitude;
  final double longitude;
  final bool isDeliveryAvailable;

  const CityEntity({
    required this.id,
    required this.pagetitle,
    required this.alias,
    required this.published,
    required this.latitude,
    required this.longitude,
    required this.isDeliveryAvailable,
  });

  @override
  List<Object?> get props => [
        id,
        pagetitle,
        alias,
        published,
        latitude,
        longitude,
        isDeliveryAvailable
      ];
}

import 'package:equatable/equatable.dart';

abstract class BasePharmacyEntity extends Equatable {
  final int pharmacyId;
  final String pharmacyName;
  final String address;
  final String coordinates;
  final String schedule;

  const BasePharmacyEntity({
    required this.pharmacyId,
    required this.pharmacyName,
    required this.address,
    required this.coordinates,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    return {
      'pharmacy_id': pharmacyId,
      'pharmacy_name': pharmacyName,
      'address': address,
      'coordinates': coordinates,
      'schedule': schedule,
    };
  }

  @override
  List<Object?> get props =>
      [pharmacyId, pharmacyName, address, coordinates, schedule];
}

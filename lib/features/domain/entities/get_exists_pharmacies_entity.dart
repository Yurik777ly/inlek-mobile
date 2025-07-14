import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class GetExistsPharmaciesEntity extends Equatable {
  final List<PharmacyEntity> pharmacies;
  final ProductEntity product;

  const GetExistsPharmaciesEntity({
    required this.pharmacies,
    required this.product,
  });

  GetExistsPharmaciesEntity copyWith({
    List<PharmacyEntity>? pharmacies,
    ProductEntity? product,
  }) {
    return GetExistsPharmaciesEntity(
      pharmacies: pharmacies ?? this.pharmacies,
      product: product ?? this.product,
    );
  }

  @override
  List<Object?> get props => [
        pharmacies,
        product,
      ];
}

import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class ProductPricesEntity extends Equatable {
  final double? price;
  final double? priceOld;
  final double? finalPrice;
  final List<PromocodeEntity> appliedPromocodes;
  final double? discountOnlyPromos;
  final double? discountWithPromos;
  final double? discountWithoutPromos;
  final double? finalPriceWithPromos;

  const ProductPricesEntity({
    this.price,
    this.priceOld,
    this.finalPrice,
    this.appliedPromocodes = const [],
    this.discountOnlyPromos,
    this.discountWithPromos,
    this.discountWithoutPromos,
    this.finalPriceWithPromos,
  });

  ProductPricesEntity copyWith({
    double? price,
    double? priceOld,
    double? finalPrice,
    List<PromocodeEntity>? appliedPromocodes,
    double? discountOnlyPromos,
    double? discountWithPromos,
    double? discountWithoutPromos,
    double? finalPriceWithPromos,
  }) {
    return ProductPricesEntity(
      price: price ?? this.price,
      priceOld: priceOld ?? this.priceOld,
      finalPrice: finalPrice ?? this.finalPrice,
      appliedPromocodes: appliedPromocodes ?? this.appliedPromocodes,
      discountOnlyPromos: discountOnlyPromos ?? this.discountOnlyPromos,
      discountWithPromos: discountWithPromos ?? this.discountWithPromos,
      discountWithoutPromos:
          discountWithoutPromos ?? this.discountWithoutPromos,
      finalPriceWithPromos: finalPriceWithPromos ?? this.finalPriceWithPromos,
    );
  }

  @override
  List<Object?> get props => [
        price,
        priceOld,
        finalPrice,
        appliedPromocodes,
        discountOnlyPromos,
        discountWithPromos,
        discountWithoutPromos,
        finalPriceWithPromos,
      ];
}

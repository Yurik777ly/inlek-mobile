import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/product_prices_entity.dart';

class ProductPricesModel extends ProductPricesEntity {
  const ProductPricesModel({
    super.price,
    super.priceOld,
    super.finalPrice,
    super.appliedPromocodes,
    super.discountOnlyPromos,
    super.discountWithPromos,
    super.discountWithoutPromos,
    super.finalPriceWithPromos,
  });

  factory ProductPricesModel.fromJson(Map<String, dynamic> json) {
    return ProductPricesModel(
      price: json["price"]?.toDouble(),
      priceOld: json["price_old"]?.toDouble(),
      finalPrice: json["final_price"]?.toDouble(),
      appliedPromocodes: json["applied_promocodes"] != null
          ? (json["applied_promocodes"] as List)
              .map((e) => PromocodeModel.fromJson(e))
              .toList()
          : [],
      discountOnlyPromos: json["discount_only_promos"]?.toDouble(),
      discountWithPromos: json["discount_with_promos"]?.toDouble(),
      discountWithoutPromos: json["discount_without_promos"]?.toDouble(),
      finalPriceWithPromos: json["final_price_with_promos"]?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "price": price,
        "price_old": priceOld,
        "final_price": finalPrice,
        "applied_promocodes": (appliedPromocodes as PromocodeModel?)?.toJson(),
        "discount_only_promos": discountOnlyPromos,
        "discount_with_promos": discountWithPromos,
        "discount_without_promos": discountWithoutPromos,
        "final_price_with_promos": finalPriceWithPromos,
      };

  @override
  ProductPricesModel copyWith({
    double? price,
    double? priceOld,
    double? finalPrice,
    List<PromocodeEntity>? appliedPromocodes,
    double? discountOnlyPromos,
    double? discountWithPromos,
    double? discountWithoutPromos,
    double? finalPriceWithPromos,
  }) {
    return ProductPricesModel(
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
}

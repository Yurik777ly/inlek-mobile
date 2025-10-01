import 'package:inlek/constants/enums.dart';
import 'package:inlek/features/domain/entities/base_pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/base_product_entity.dart';

class CartPharmaciesProductEntity extends BaseProductEntity {
  final int? requestedQuantity;
  final int? stockCount;
  final String? availability;
  final double? price;
  final double? oldPrice;
  final bool? isRecipe;
  final bool? isAlcohol;
  final TypeReceiving? delivery;

  const CartPharmaciesProductEntity(
      {required super.productId,
      required super.name,
      required super.image,
      this.requestedQuantity,
      this.stockCount,
      this.availability,
      this.price,
      this.oldPrice,
      this.isRecipe,
      this.isAlcohol,
      this.delivery});

  @override
  List<Object?> get props =>
      super.props +
      [
        requestedQuantity,
        stockCount,
        availability,
        price,
        oldPrice,
        isRecipe,
        isAlcohol,
        delivery,
      ];
}

class CartPharmacyEntity extends BasePharmacyEntity {
  final int distanceMeters;
  final List<CartPharmaciesProductEntity> products;
  final int totalProducts;
  final double totalPrice;
  final double totalPriceOld;
  final double totalDiscount;
  final String? availability;

  const CartPharmacyEntity({
    required super.pharmacyId,
    required super.pharmacyName,
    required super.address,
    required super.coordinates,
    required super.schedule,
    required this.distanceMeters,
    required this.products,
    required this.totalProducts,
    required this.totalPrice,
    required this.totalPriceOld,
    required this.totalDiscount,
    this.availability,
  });

  @override
  List<Object?> get props =>
      super.props +
      [
        distanceMeters,
        products,
        totalProducts,
        totalPrice,
        totalPriceOld,
        totalDiscount,
        availability
      ];
}

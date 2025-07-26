import 'package:inlek/features/domain/entities/base_pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class PharmacyEntity extends BasePharmacyEntity {
  final String? pageTitle;
  final String? alias;
  final double? price;
  final double? priceOld;
  final int? productId;
  final int? stockCount;
  final int? requiredQuantity;
  final String? availability;
  final String? productName;
  final String? expirationDate;
  final String? pharmacyDelivery;
  final List<ProductEntity> products;
  final String? image;

  const PharmacyEntity({
    required super.pharmacyId,
    required super.pharmacyName,
    required super.address,
    required super.coordinates,
    required super.schedule,
    this.pageTitle,
    this.alias,
    this.price,
    this.priceOld,
    this.productId,
    this.stockCount,
    this.requiredQuantity,
    this.availability,
    this.productName,
    this.expirationDate,
    this.pharmacyDelivery,
    this.products = const [],
    this.image,
  });

  PharmacyEntity copyWith({
    int? pharmacyId,
    String? pharmacyName,
    String? address,
    String? coordinates,
    String? schedule,
    String? pageTitle,
    String? alias,
    double? price,
    double? priceOld,
    int? productId,
    int? stockCount,
    int? requiredQuantity,
    String? availability,
    String? productName,
    String? expirationDate,
    String? pharmacyDelivery,
    List<ProductEntity>? products,
    String? image,
  }) =>
      PharmacyEntity(
        pharmacyId: pharmacyId ?? this.pharmacyId,
        pharmacyName: pharmacyName ?? this.pharmacyName,
        address: address ?? this.address,
        coordinates: coordinates ?? this.coordinates,
        schedule: schedule ?? this.schedule,
        pageTitle: pageTitle ?? this.pageTitle,
        alias: alias ?? this.alias,
        price: price ?? this.price,
        priceOld: priceOld ?? this.priceOld,
        productId: productId ?? this.productId,
        stockCount: stockCount ?? this.stockCount,
        requiredQuantity: requiredQuantity ?? this.requiredQuantity,
        availability: availability ?? this.availability,
        productName: productName ?? this.productName,
        expirationDate: expirationDate ?? this.expirationDate,
        pharmacyDelivery: pharmacyDelivery ?? this.pharmacyDelivery,
        products: products ?? this.products,
        image: image ?? this.image,
      );

  @override
  List<Object?> get props =>
      super.props +
      [
        pageTitle,
        alias,
        price,
        priceOld,
        productId,
        stockCount,
        requiredQuantity,
        availability,
        productName,
        expirationDate,
        pharmacyDelivery,
        products,
        image,
      ];
}

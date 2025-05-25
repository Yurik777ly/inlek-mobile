import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class PharmacyEntity extends Equatable {
  final int? pharmacyId;
  final String? pageTitle;
  final String? alias;
  final String? address;
  final String? coordinates;
  final String? image;
  final String? schedule;
  final double? price;
  final double? priceOld;
  final int? productId;
  final int? stockCount;
  final int? requiredQuantity;
  final String? availability;
  final String? productName;
  final String? pharmacyName;
  final String? expirationDate;
  final String? pharmacyDelivery;
  final List<ProductEntity> products;

  const PharmacyEntity({
    this.pharmacyId,
    this.pageTitle,
    this.alias,
    this.address,
    this.coordinates,
    this.image,
    this.schedule,
    this.price,
    this.priceOld,
    this.productId,
    this.stockCount,
    this.requiredQuantity,
    this.availability,
    this.productName,
    this.pharmacyName,
    this.expirationDate,
    this.pharmacyDelivery,
    this.products = const [],
  });

  PharmacyEntity copyWith({
    int? pharmacyId,
    String? pageTitle,
    String? alias,
    String? address,
    String? coordinates,
    String? image,
    String? schedule,
    double? price,
    double? priceOld,
    int? productId,
    int? stockCount,
    int? requiredQuantity,
    String? availability,
    String? productName,
    String? pharmacyName,
    String? expirationDate,
    String? pharmacyDelivery,
    List<ProductEntity>? products,
  }) =>
      PharmacyEntity(
        pharmacyId: pharmacyId ?? this.pharmacyId,
        pageTitle: pageTitle ?? this.pageTitle,
        alias: alias ?? this.alias,
        address: address ?? this.address,
        coordinates: coordinates ?? this.coordinates,
        image: image ?? this.image,
        schedule: schedule ?? this.schedule,
        price: price ?? this.price,
        priceOld: priceOld ?? this.priceOld,
        productId: productId ?? this.productId,
        stockCount: stockCount ?? this.stockCount,
        requiredQuantity: requiredQuantity ?? this.requiredQuantity,
        availability: availability ?? this.availability,
        productName: productName ?? this.productName,
        pharmacyName: pharmacyName ?? this.pharmacyName,
        expirationDate: expirationDate ?? this.expirationDate,
        pharmacyDelivery: pharmacyDelivery ?? this.pharmacyDelivery,
        products: products ?? this.products,
      );

  @override
  List<Object?> get props => [
        pharmacyId,
        pageTitle,
        alias,
        address,
        coordinates,
        image,
        schedule,
        price,
        priceOld,
        productId,
        stockCount,
        requiredQuantity,
        availability,
        productName,
        pharmacyName,
        expirationDate,
        pharmacyDelivery,
        products,
      ];
}

import 'package:equatable/equatable.dart';

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
  final String? productName;
  final String? pharmacyName;
  final String? expirationDate;
  final String? pharmacyDelivery;

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
    this.productName,
    this.pharmacyName,
    this.expirationDate,
    this.pharmacyDelivery,
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
    String? productName,
    String? pharmacyName,
    String? expirationDate,
    String? pharmacyDelivery,
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
        productName: productName ?? this.productName,
        pharmacyName: pharmacyName ?? this.pharmacyName,
        expirationDate: expirationDate ?? this.expirationDate,
        pharmacyDelivery: pharmacyDelivery ?? this.pharmacyDelivery,
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
        productName,
        pharmacyName,
        expirationDate,
        pharmacyDelivery,
      ];
}

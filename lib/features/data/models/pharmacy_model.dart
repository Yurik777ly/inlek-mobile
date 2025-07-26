import 'dart:convert';

import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';

class PharmacyModel extends PharmacyEntity {
  const PharmacyModel({
    super.pageTitle,
    super.alias,
    super.image,
    super.price,
    super.priceOld,
    super.productId,
    super.stockCount,
    super.requiredQuantity,
    super.availability,
    super.productName,
    super.expirationDate,
    super.pharmacyDelivery,
    super.products,
    required super.pharmacyId,
    required super.pharmacyName,
    required super.address,
    required super.coordinates,
    required super.schedule,
  });

  factory PharmacyModel.fromRawJson(String str) =>
      PharmacyModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PharmacyModel.fromJson(Map<String, dynamic> json) => PharmacyModel(
        pharmacyId: json["pharmacy_id"],
        pageTitle: json["pagetitle"],
        alias: json["alias"],
        address: json["address"],
        coordinates: json["coordinates"],
        image: json["image"],
        schedule: json["schedule"],
        price: (json["price"] as num?)?.toDouble(),
        priceOld: (json["price_old"] as num?)?.toDouble(),
        productId: json["product_id"],
        stockCount: _parseStockCount(json["stock_count"]),
        requiredQuantity: json["required_quantity"],
        availability: json["availability"],
        productName: json["product_name"],
        pharmacyName: json["pharmacy_name"] ?? json["pagetitle"],
        expirationDate: json["expiration_date"],
        pharmacyDelivery: json["pharmacy_delivery"],
        products: json["products"] != null
            ? (json["products"] as List)
                .map((e) => ProductModel.fromJson(e))
                .toList()
            : [],
      );

  @override
  Map<String, dynamic> toJson() => {
        "pharmacy_id": pharmacyId,
        "pagetitle": pageTitle,
        "alias": alias,
        "address": address,
        "coordinates": coordinates,
        "image": image,
        "schedule": schedule,
        "price": price,
        "price_old": priceOld,
        "product_id": productId,
        "availability": availability,
        "stock_count": stockCount?.toString(),
        "required_quantity": requiredQuantity,
        "product_name": productName,
        "pharmacy_name": pharmacyName,
        "expiration_date": expirationDate,
        "pharmacy_delivery": pharmacyDelivery,
        "products":
            products.map((e) => (e as ProductModel?)?.toJson()).toList(),
      };

  static int? _parseStockCount(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) {
      return value.floor();
    }

    if (value is String) {
      final doubleVal = double.tryParse(value);
      return doubleVal?.floor();
    }

    return null;
  }
}

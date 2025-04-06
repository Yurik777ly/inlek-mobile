import 'dart:convert';

import 'package:inlek/features/domain/entities/pharmacy_entity.dart';

class PharmacyModel extends PharmacyEntity {
  const PharmacyModel({
    super.pharmacyId,
    super.pageTitle,
    super.alias,
    super.address,
    super.coordinates,
    super.image,
    super.schedule,
    super.price,
    super.priceOld,
    super.productId,
    super.stockCount,
    super.productName,
    super.pharmacyName,
    super.expirationDate,
    super.pharmacyDelivery,
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
        stockCount: int.tryParse(json["stock_count"]?.toString() ?? "0"),
        productName: json["product_name"],
        pharmacyName: json["pharmacy_name"],
        expirationDate: json["expiration_date"],
        pharmacyDelivery: json["pharmacy_delivery"],
      );

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
        "stock_count": stockCount?.toString(),
        "product_name": productName,
        "pharmacy_name": pharmacyName,
        "expiration_date": expirationDate,
        "pharmacy_delivery": pharmacyDelivery,
      };
}

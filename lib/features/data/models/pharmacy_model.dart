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

  factory PharmacyModel.fromJson(dynamic json) {
    if (json is String) {
      return PharmacyModel.fromJson(jsonDecode(json));
    }

    if (json is! Map) {
      throw const FormatException('Invalid pharmacy JSON');
    }

    final map = Map<String, dynamic>.from(json);

    return PharmacyModel(
      pharmacyId: _parseInt(map['pharmacy_id']) ?? 0,
      pageTitle: _asString(map['pagetitle']),
      alias: _asString(map['alias']),
      address: _asString(map['address']) ?? '',
      coordinates: _asString(map['coordinates']) ?? '',
      image: _asString(map['image']),
      schedule: _asString(map['schedule']) ?? '',
      price: _parseDouble(map['price']),
      priceOld: _parseDouble(map['price_old']),
      productId: _parseInt(map['product_id']),
      stockCount: _parseStockCount(map['stock_count']),
      requiredQuantity: map['required_quantity'],
      availability: _asString(map['availability']),
      productName: _asString(map['product_name']),
      pharmacyName: _asString(map['pharmacy_name'] ?? map['pagetitle']) ?? '',
      expirationDate: _formatExpirationDate(map['expiration_date']),
      pharmacyDelivery: _asString(map['pharmacy_delivery']),
      products: map['products'] is List
          ? (map['products'] as List)
              .whereType<Map>()
              .map(
                (item) => ProductModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }

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

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value.trim();
    }

    return value.toString();
  }

  static String? _formatExpirationDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    return value.toString();
  }

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

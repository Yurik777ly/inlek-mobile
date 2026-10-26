import 'package:inlek/constants/pharmacy_utils.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';

int? _cartParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.floor();
  return int.tryParse(value.toString());
}

double? _cartParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _cartAsString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.trim();
  return value.toString();
}

class CartPharmaciesProductModel extends CartPharmaciesProductEntity {
  const CartPharmaciesProductModel({
    required super.productId,
    required super.name,
    required super.image,
    super.requestedQuantity,
    super.stockCount,
    super.availability,
    super.price,
    super.oldPrice,
    super.isRecipe,
    super.isAlcohol,
    super.delivery,
    super.otherPharmacy,
  });

  factory CartPharmaciesProductModel.fromJson(Map<String, dynamic> json) =>
      CartPharmaciesProductModel(
        productId: _cartParseInt(json['product_id']) ?? 0,
        name: _cartAsString(json['name']) ?? '',
        image: _cartAsString(json['image']) ?? '',
        requestedQuantity: _cartParseInt(json['requested_quantity']),
        stockCount: _cartParseInt(json['stock_count']) ?? 0,
        availability: _cartAsString(json['availability']),
        price: _cartParseDouble(json['price']),
        oldPrice: _cartParseDouble(json['price_old']),
        isRecipe: json['is_recipe'] == true || json['is_recipe'] == 1,
        isAlcohol: json['is_alcohol'] == true || json['is_alcohol'] == 1,
        delivery: json['delivery'],
        otherPharmacy: _cartParseInt(json['other_pharmacy']),
      );
}

class CartPharmacyModel extends CartPharmacyEntity {
  const CartPharmacyModel({
    required super.pharmacyId,
    required super.pharmacyName,
    super.address = '',
    super.coordinates = '',
    super.schedule = '',
    super.distanceMeters = 0,
    super.products = const [],
    super.totalProducts = 0,
    super.totalPrice = 0,
    super.totalPriceOld = 0,
    super.totalDiscount = 0,
    super.availability,
    super.requestedQuantity,
    super.sumAvailability,
  });

  factory CartPharmacyModel.fromJson(Map<String, dynamic> json) =>
      CartPharmacyModel(
        pharmacyId: _cartParseInt(json['pharmacy_id']) ?? 0,
        pharmacyName: _cartAsString(json['pharmacy_name']) ?? '',
        address: _cartAsString(json['address']) ?? '',
        coordinates: _cartAsString(json['coordinates']) ?? '',
        schedule: PharmacyUtils.normalizeSchedule(json['schedule']),
        distanceMeters: _cartParseInt(json['distance_meters']) ?? 0,
        products: (json['products'] as List?)
                ?.whereType<Map>()
                .map(
                  (e) => CartPharmaciesProductModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList() ??
            [],
        totalProducts: _cartParseInt(json['total_products']) ?? 0,
        totalPrice: _cartParseDouble(json['total_price']) ?? 0.0,
        totalPriceOld: _cartParseDouble(json['total_price_old']) ?? 0.0,
        totalDiscount: _cartParseDouble(json['total_discount']) ?? 0.0,
        availability: _cartAsString(json['availability']) ?? 'full',
        requestedQuantity: _cartParseInt(json['requested_quantity']),
        sumAvailability: _cartAsString(json['sum_availability']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'pharmacy_id': pharmacyId,
        'pharmacy_name': pharmacyName,
        'address': address,
        'coordinates': coordinates,
        'schedule': schedule,
        'distance_meters': distanceMeters,
        'products': products
            .map((e) => (e as CartPharmaciesProductModel).toJson())
            .toList(),
        'total_products': totalProducts,
        'total_price': totalPrice,
        'total_price_old': totalPriceOld,
        'total_discount': totalDiscount,
        'availability': availability,
      };
}

extension CartPharmaciesProductModelToJson on CartPharmaciesProductModel {
  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'image': image,
        'requested_quantity': requestedQuantity,
        'stock_count': stockCount,
        'availability': availability,
        'price': price,
        'price_old': oldPrice,
        'is_recipe': isRecipe,
        'is_alcohol': isAlcohol,
      };
}

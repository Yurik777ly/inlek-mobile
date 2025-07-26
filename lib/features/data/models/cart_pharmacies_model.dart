import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';

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
  });

  factory CartPharmaciesProductModel.fromJson(Map<String, dynamic> json) =>
      CartPharmaciesProductModel(
        productId: json['product_id'],
        name: json['name'],
        image: json['image'],
        requestedQuantity: json['requested_quantity'],
        stockCount: json['stock_count'] != null
            ? (json['stock_count'] as num).toInt()
            : 0,
        availability: json['availability'],
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        oldPrice: json['price_old'] != null
            ? (json['price_old'] as num).toDouble()
            : null,
        isRecipe: json['is_recipe'] ?? false,
        isAlcohol: json['is_alcohol'] ?? false,
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
    super.isOutOfStock = false,
    super.availability,
  });

  factory CartPharmacyModel.fromJson(Map<String, dynamic> json) =>
      CartPharmacyModel(
        pharmacyId: json['pharmacy_id'],
        pharmacyName: json['pharmacy_name'],
        address: json['address'],
        coordinates: json['coordinates'],
        schedule: json['schedule'],
        distanceMeters: json['distance_meters'],
        products: (json['products'] as List)
            .map((e) => CartPharmaciesProductModel.fromJson(e))
            .toList(),
        totalProducts: json['total_products'],
        totalPrice: (json['total_price'] as num).toDouble(),
        totalPriceOld: (json['total_price_old'] as num).toDouble(),
        totalDiscount: (json['total_discount'] as num).toDouble(),
        isOutOfStock: json['is_out_of_stock'],
        availability: json['availability'],
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
            .map((e) => (e as CartPharmaciesProductModel?)?.toJson())
            .toList(),
        'total_products': totalProducts,
        'total_price': totalPrice,
        'total_price_old': totalPriceOld,
        'total_discount': totalDiscount,
        'is_out_of_stock': isOutOfStock,
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

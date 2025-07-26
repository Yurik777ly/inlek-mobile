import 'package:equatable/equatable.dart';

class CartPharmaciesProductParam extends Equatable {
  final int productId;
  final int quantity;

  const CartPharmaciesProductParam(
      {required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };

  @override
  List<Object?> get props => [productId, quantity];
}

class CartPharmaciesParam extends Equatable {
  final double geoLat;
  final double geoLong;
  final List<CartPharmaciesProductParam> products;

  const CartPharmaciesParam(
      {required this.geoLat, required this.geoLong, required this.products});

  Map<String, dynamic> toJson() => {
        'geo_lat': geoLat,
        'geo_long': geoLong,
        'products': products.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [geoLat, geoLong, products];
}

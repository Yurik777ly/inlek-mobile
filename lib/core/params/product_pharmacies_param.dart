import 'package:equatable/equatable.dart';

class ProductPharmaciesParam extends Equatable {
  final double geoLat;
  final double geoLong;
  final int productId;

  const ProductPharmaciesParam(
      {required this.geoLat, required this.geoLong, required this.productId});

  Map<String, dynamic> toJson() => {
        'geo_lat': geoLat,
        'geo_long': geoLong,
        'products_id': productId,
      };

  @override
  List<Object?> get props => [geoLat, geoLong, productId];
}

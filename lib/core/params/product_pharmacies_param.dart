import 'package:equatable/equatable.dart';

class ProductPharmaciesParam extends Equatable {
  final double? geoLat;
  final double? geoLong;
  final int productId;

  const ProductPharmaciesParam({
    this.geoLat,
    this.geoLong,
    required this.productId,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    if (geoLat != null) {
      params['geo_lat'] = geoLat.toString();
    }
    if (geoLong != null) {
      params['geo_long'] = geoLong.toString();
    }

    return params;
  }

  @override
  List<Object?> get props => [geoLat, geoLong, productId];
}

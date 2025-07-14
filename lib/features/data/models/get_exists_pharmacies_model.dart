import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/get_exists_pharmacies_entity.dart';

class GetExistsPharmaciesModel extends GetExistsPharmaciesEntity {
  const GetExistsPharmaciesModel({
    required super.pharmacies,
    required super.product,
  });

  factory GetExistsPharmaciesModel.fromJson(Map<String, dynamic> json) {
    return GetExistsPharmaciesModel(
      pharmacies: json['pharmacies'] != null
          ? (json['pharmacies'] as List)
              .map((e) => PharmacyModel.fromJson(e))
              .toList()
          : [],
      product: ProductModel(
        requiredQuantity: json['required_quantity'],
        productId: json['product_id'],
      ),
    );
  }
}

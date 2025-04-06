import 'package:inlek/features/data/models/category_model.dart';
import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/search_products_v2_entity.dart';

class SearchProductsV2Model extends SearchProductsV2Entity {
  const SearchProductsV2Model({
    required super.categories,
    required super.products,
  });

  factory SearchProductsV2Model.fromJson(Map<String, dynamic> json) {
    return SearchProductsV2Model(
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList()
          : [],
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

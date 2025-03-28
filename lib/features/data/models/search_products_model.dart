import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/search_products_entity.dart';

class SearchProductsModel extends SearchProductsEntity {
  const SearchProductsModel({
    required super.currentPage,
    required super.lastPage,
    required super.total,
    required super.products,
  });

  factory SearchProductsModel.fromJson(Map<String, dynamic> json) {
    return SearchProductsModel(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
      products: json['data'] != null
          ? (json['data'] as List).map((e) => ProductModel.fromJson(e)).toList()
          : [],
    );
  }
}

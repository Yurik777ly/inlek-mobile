import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class SearchProductsV2Entity extends Equatable {
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;

  const SearchProductsV2Entity({
    required this.categories,
    required this.products,
  });

  SearchProductsV2Entity copyWith({
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
  }) {
    return SearchProductsV2Entity(
      categories: categories ?? this.categories,
      products: products ?? this.products,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        products,
      ];
}

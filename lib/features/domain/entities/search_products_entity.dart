import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class SearchProductsEntity extends Equatable {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<ProductEntity> products;

  const SearchProductsEntity({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.products,
  });

  // Добавляем метод copyWith
  SearchProductsEntity copyWith({
    int? currentPage,
    int? lastPage,
    int? total,
    List<ProductEntity>? products,
  }) {
    return SearchProductsEntity(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      products: products ?? this.products,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        lastPage,
        total,
        products,
      ];
}

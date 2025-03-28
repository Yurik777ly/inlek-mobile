part of 'products_screen_bloc.dart';

class ProductsScreenState extends Equatable {
  final bool isLoading;
  final bool isLoadingProducts;
  final String? error;
  final ProductSortType productSortType;
  final SearchProductsEntity? searchProducts;

  const ProductsScreenState({
    this.isLoading = true,
    this.isLoadingProducts = false,
    this.error,
    this.productSortType = ProductSortType.popularity,
    this.searchProducts,
  });

  ProductsScreenState copyWith({
    bool? isLoading,
    bool? isLoadingProducts,
    String? error,
    ProductSortType? productSortType,
    SearchProductsEntity? searchProducts,
  }) {
    return ProductsScreenState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      error: error ?? this.error,
      productSortType: productSortType ?? this.productSortType,
      searchProducts: searchProducts ?? this.searchProducts,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isLoadingProducts, error, productSortType, searchProducts];
}

part of 'product_screen_bloc.dart';

class ProductScreenState extends Equatable {
  final bool isLoadingProducts;
  final bool isLoadingPharmacies;
  final String? error;
  final String? errorPharmacies;

  final ProductEntity? product;
  final List<PharmacyEntity>? pharmacies;

  const ProductScreenState({
    this.isLoadingProducts = true,
    this.isLoadingPharmacies = true,
    this.error,
    this.errorPharmacies,
    this.product,
    this.pharmacies,
  });

  ProductScreenState copyWith({
    bool? isLoadingProducts,
    bool? isLoadingPharmacies,
    String? error,
    String? errorPharmacies,
    ProductEntity? product,
    List<PharmacyEntity>? pharmacies,
  }) {
    return ProductScreenState(
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingPharmacies: isLoadingPharmacies ?? this.isLoadingPharmacies,
      error: error ?? this.error,
      errorPharmacies: errorPharmacies ?? this.errorPharmacies,
      product: product ?? this.product,
      pharmacies: pharmacies ?? this.pharmacies,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingProducts,
        isLoadingPharmacies,
        error,
        errorPharmacies,
        product,
        pharmacies
      ];
}

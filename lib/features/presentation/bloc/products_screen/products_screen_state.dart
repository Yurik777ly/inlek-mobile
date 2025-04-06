part of 'products_screen_bloc.dart';

class ProductsScreenState extends Equatable {
  final bool isLoading;
  final bool isLoadingProducts;
  final bool filtersLoaded;
  final String? error;
  final ProductSortType productSortType;
  final SearchProductsEntity? searchProducts;
  final double minAllowedPrice;
  final double maxAllowedPrice;
  final double minSelectedPrice;
  final double maxSelectedPrice;
  final List<String> releaseForms;
  final Set<String> selectedReleaseForms;
  final List<String> manufacturers;
  final Set<String> selectedManufacturers;
  final List<String> countries;
  final Set<String> selectedCountries;
  final bool isWithoutPrescription;
  final bool isParticipatesInCampaign;
  final bool isDeliveryPossible;

  const ProductsScreenState({
    this.isLoading = true,
    this.isLoadingProducts = false,
    this.filtersLoaded = false,
    this.error,
    this.productSortType = ProductSortType.popularity,
    this.searchProducts,
    this.minAllowedPrice = 0,
    this.maxAllowedPrice = 50,
    this.minSelectedPrice = 0,
    this.maxSelectedPrice = 50,
    this.releaseForms = const [],
    this.selectedReleaseForms = const {},
    this.manufacturers = const [],
    this.selectedManufacturers = const {},
    this.countries = const [],
    this.selectedCountries = const {},
    this.isWithoutPrescription = false,
    this.isParticipatesInCampaign = false,
    this.isDeliveryPossible = false,
  });

  ProductsScreenState copyWith({
    bool? isLoading,
    bool? isLoadingProducts,
    bool? filtersLoaded,
    String? error,
    ProductSortType? productSortType,
    SearchProductsEntity? searchProducts,
    double? minAllowedPrice,
    double? maxAllowedPrice,
    double? minSelectedPrice,
    double? maxSelectedPrice,
    List<String>? releaseForms,
    Set<String>? selectedReleaseForms,
    List<String>? manufacturers,
    Set<String>? selectedManufacturers,
    List<String>? countries,
    Set<String>? selectedCountries,
    bool? isWithoutPrescription,
    bool? isParticipatesInCampaign,
    bool? isDeliveryPossible,
  }) {
    return ProductsScreenState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      filtersLoaded: filtersLoaded ?? this.filtersLoaded,
      error: error ?? this.error,
      productSortType: productSortType ?? this.productSortType,
      searchProducts: searchProducts ?? this.searchProducts,
      minAllowedPrice: minAllowedPrice ?? this.minAllowedPrice,
      maxAllowedPrice: maxAllowedPrice ?? this.maxAllowedPrice,
      minSelectedPrice: minSelectedPrice ?? this.minSelectedPrice,
      maxSelectedPrice: maxSelectedPrice ?? this.maxSelectedPrice,
      releaseForms: releaseForms ?? this.releaseForms,
      selectedReleaseForms: selectedReleaseForms ?? this.selectedReleaseForms,
      manufacturers: manufacturers ?? this.manufacturers,
      selectedManufacturers:
          selectedManufacturers ?? this.selectedManufacturers,
      countries: countries ?? this.countries,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      isWithoutPrescription:
          isWithoutPrescription ?? this.isWithoutPrescription,
      isParticipatesInCampaign:
          isParticipatesInCampaign ?? this.isParticipatesInCampaign,
      isDeliveryPossible: isDeliveryPossible ?? this.isDeliveryPossible,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingProducts,
        filtersLoaded,
        error,
        productSortType,
        searchProducts,
        minAllowedPrice,
        maxAllowedPrice,
        minSelectedPrice,
        maxSelectedPrice,
        releaseForms,
        selectedReleaseForms,
        manufacturers,
        selectedManufacturers,
        countries,
        selectedCountries,
        isWithoutPrescription,
        isParticipatesInCampaign,
        isDeliveryPossible,
      ];
}

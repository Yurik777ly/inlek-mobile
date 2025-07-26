part of 'pharmacies_cart_screen_bloc.dart';

class PharmaciesCartScreenState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final List<CartPharmacyEntity> pharmacies;
  final List<CartPharmacyEntity> filteredPharmacies;
  final int selectorIndex;
  final TypeReceiving pharmacySortType;
  final String query;
  final List<CustomMapObject> mapObjects;
  final bool showWorkingNowOnly;
  final bool showWithAllProductsOnly;

  const PharmaciesCartScreenState({
    this.isLoading = true,
    this.hasError = false,
    this.pharmacies = const [],
    this.filteredPharmacies = const [],
    this.selectorIndex = 0,
    this.pharmacySortType = TypeReceiving.all,
    this.query = '',
    this.mapObjects = const [],
    this.showWorkingNowOnly = false,
    this.showWithAllProductsOnly = false,
  });

  PharmaciesCartScreenState copyWith({
    bool? isLoading,
    bool? hasError,
    List<CartPharmacyEntity>? pharmacies,
    List<CartPharmacyEntity>? filteredPharmacies,
    int? selectorIndex,
    TypeReceiving? pharmacySortType,
    String? query,
    List<CustomMapObject>? mapObjects,
    bool? showWorkingNowOnly,
    bool? showWithAllProductsOnly,
  }) {
    return PharmaciesCartScreenState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      pharmacies: pharmacies ?? this.pharmacies,
      filteredPharmacies: filteredPharmacies ?? this.filteredPharmacies,
      selectorIndex: selectorIndex ?? this.selectorIndex,
      pharmacySortType: pharmacySortType ?? this.pharmacySortType,
      query: query ?? this.query,
      mapObjects: mapObjects ?? this.mapObjects,
      showWorkingNowOnly: showWorkingNowOnly ?? this.showWorkingNowOnly,
      showWithAllProductsOnly:
          showWithAllProductsOnly ?? this.showWithAllProductsOnly,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        hasError,
        pharmacies,
        filteredPharmacies,
        selectorIndex,
        pharmacySortType,
        query,
        mapObjects,
        showWorkingNowOnly,
        showWithAllProductsOnly,
      ];
}

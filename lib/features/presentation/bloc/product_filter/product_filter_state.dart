part of 'product_filter_bloc.dart';

class ProductFilterState extends Equatable {
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

  final bool? isLoading;

  const ProductFilterState({
    this.minAllowedPrice = 0,
    this.maxAllowedPrice = 0,
    this.minSelectedPrice = 50,
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
    this.isLoading = true,
  });

  ProductFilterState copyWith({
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
    bool? isLoading,
  }) {
    return ProductFilterState(
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
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
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
        isLoading,
      ];
}

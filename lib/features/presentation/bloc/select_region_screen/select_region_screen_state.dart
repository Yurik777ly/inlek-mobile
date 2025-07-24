part of 'select_region_screen_bloc.dart';

class SelectRegionScreenState extends Equatable {
  final bool isButtonActive;
  final bool showError;
  final List<String> popularCities;
  final String? selectedRegion;
  final String? detectedCity;

  const SelectRegionScreenState({
    this.isButtonActive = false,
    this.showError = false,
    this.selectedRegion,
    this.popularCities = const [],
    this.detectedCity,
  });

  SelectRegionScreenState copyWith({
    bool? isButtonActive,
    bool? showError,
    List<String>? popularCities,
    String? selectedRegion,
    String? detectedCity,
  }) {
    return SelectRegionScreenState(
      isButtonActive: isButtonActive ?? this.isButtonActive,
      showError: showError ?? this.showError,
      popularCities: popularCities ?? this.popularCities,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      detectedCity: detectedCity ?? this.detectedCity,
    );
  }

  @override
  List<Object?> get props =>
      [isButtonActive, showError, selectedRegion, popularCities, detectedCity];
}

part of 'pharmacies_screen_bloc.dart';

class PharmaciesScreenState extends Equatable {
  final List<PharmacyEntity> pharmacies;
  final List<PharmacyEntity> filteredPharmacies;
  final int selectorIndex;
  final TypeReceiving pharmacySortType;
  final String query;
  final List<CustomMapObject> mapObjects;

  const PharmaciesScreenState({
    this.pharmacies = const [],
    this.filteredPharmacies = const [],
    this.selectorIndex = 0,
    this.pharmacySortType = TypeReceiving.all,
    this.query = '',
    this.mapObjects = const [],
  });

  PharmaciesScreenState copyWith({
    List<PharmacyEntity>? pharmacies,
    List<PharmacyEntity>? filteredPharmacies,
    int? selectorIndex,
    TypeReceiving? pharmacySortType,
    String? query,
    List<CustomMapObject>? mapObjects,
  }) {
    return PharmaciesScreenState(
      pharmacies: pharmacies ?? this.pharmacies,
      filteredPharmacies: filteredPharmacies ?? this.filteredPharmacies,
      selectorIndex: selectorIndex ?? this.selectorIndex,
      pharmacySortType: pharmacySortType ?? this.pharmacySortType,
      query: query ?? this.query,
      mapObjects: mapObjects ?? this.mapObjects,
    );
  }

  @override
  List<Object?> get props => [
        pharmacies,
        filteredPharmacies,
        selectorIndex,
        pharmacySortType,
        query,
        mapObjects,
      ];
}

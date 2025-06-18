part of 'pharmacies_screen_bloc.dart';

abstract class PharmaciesScreenEvent extends Equatable {
  const PharmaciesScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadPharmaciesDataEvent extends PharmaciesScreenEvent {
  final Set<int>? selectedProductIds;
  final List<PharmacyEntity>? pharmacies;

  const LoadPharmaciesDataEvent({this.selectedProductIds, this.pharmacies});
}

class ChangeSelectorIndexEvent extends PharmaciesScreenEvent {
  final int selectorIndex;
  const ChangeSelectorIndexEvent(this.selectorIndex);
}

class ChangePharmacyQueryEvent extends PharmaciesScreenEvent {
  final String query;
  const ChangePharmacyQueryEvent(this.query);
}

class ChangePharmacySortTypeEvent extends PharmaciesScreenEvent {
  final TypeReceiving pharmacySortType;

  const ChangePharmacySortTypeEvent(this.pharmacySortType);

  @override
  List<Object> get props => [pharmacySortType];
}

class ToggleShowWorkingNowOnlyEvent extends PharmaciesScreenEvent {
  final bool value;

  const ToggleShowWorkingNowOnlyEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class ToggleShowWithAllProductsOnlyEvent extends PharmaciesScreenEvent {
  final bool value;

  const ToggleShowWithAllProductsOnlyEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class CheckProductAvailableDeliveryEvent extends PharmaciesScreenEvent {}

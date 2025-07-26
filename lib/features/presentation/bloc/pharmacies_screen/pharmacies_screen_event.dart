part of 'pharmacies_screen_bloc.dart';

abstract class PharmaciesScreenEvent extends Equatable {
  const PharmaciesScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadPharmaciesDataEvent extends PharmaciesScreenEvent {
  final List<PharmacyEntity>? pharmacies;

  const LoadPharmaciesDataEvent({this.pharmacies});
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

class CheckProductAvailableDeliveryEvent extends PharmaciesScreenEvent {}

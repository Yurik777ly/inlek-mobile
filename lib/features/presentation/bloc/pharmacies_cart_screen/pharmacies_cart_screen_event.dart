part of 'pharmacies_cart_screen_bloc.dart';

abstract class PharmaciesCartScreenEvent extends Equatable {
  const PharmaciesCartScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadPharmaciesCartDataEvent extends PharmaciesCartScreenEvent {
  final List<CartPharmaciesProductParam> products;

  const LoadPharmaciesCartDataEvent({required this.products});
}

class ChangeSelectorIndexEvent extends PharmaciesCartScreenEvent {
  final int selectorIndex;
  const ChangeSelectorIndexEvent(this.selectorIndex);
}

class ChangePharmacyCartQueryEvent extends PharmaciesCartScreenEvent {
  final String query;
  const ChangePharmacyCartQueryEvent(this.query);
}

class ToggleShowWorkingNowOnlyEvent extends PharmaciesCartScreenEvent {
  final bool value;

  const ToggleShowWorkingNowOnlyEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class ToggleShowWithAllProductsOnlyEvent extends PharmaciesCartScreenEvent {
  final bool value;

  const ToggleShowWithAllProductsOnlyEvent(this.value);

  @override
  List<Object?> get props => [value];
}

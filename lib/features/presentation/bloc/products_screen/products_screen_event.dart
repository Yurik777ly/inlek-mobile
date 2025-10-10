part of 'products_screen_bloc.dart';

abstract class ProductsScreenEvent extends Equatable {
  const ProductsScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductsScreenEvent {
  final int? page;

  const LoadProductsEvent({this.page});

  @override
  List<Object?> get props => [page];
}

class ChangeProductSortTypeEvent extends ProductsScreenEvent {
  final ProductSortType? productSortType;

  const ChangeProductSortTypeEvent({this.productSortType});

  @override
  List<Object?> get props => [productSortType];
}

class ChangePriceEvent extends ProductsScreenEvent {
  final double? newPrice;
  final bool? isMinPrice;
  const ChangePriceEvent(this.newPrice, this.isMinPrice);

  @override
  List<Object?> get props => [newPrice, isMinPrice ?? false];
}

class SelectReleaseFormEvent extends ProductsScreenEvent {
  final String releaseForm;
  final bool? isChecked;
  const SelectReleaseFormEvent(this.releaseForm, this.isChecked);

  @override
  List<Object> get props => [releaseForm, isChecked ?? false];
}

class SelectManufacturerEvent extends ProductsScreenEvent {
  final String manufacturer;
  final bool? isChecked;
  const SelectManufacturerEvent(this.manufacturer, this.isChecked);

  @override
  List<Object> get props => [manufacturer, isChecked ?? false];
}

class SelectCountryEvent extends ProductsScreenEvent {
  final String country;
  final bool? isChecked;
  const SelectCountryEvent(this.country, this.isChecked);

  @override
  List<Object> get props => [country, isChecked ?? false];
}

class ToggleAvailableEvent extends ProductsScreenEvent {
  final bool? isAvailable;
  const ToggleAvailableEvent(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

class ToggleWithoutPrescriptionEvent extends ProductsScreenEvent {
  final bool? isWithoutPrescription;
  const ToggleWithoutPrescriptionEvent(this.isWithoutPrescription);

  @override
  List<Object?> get props => [isWithoutPrescription];
}

class ToggleParticipatesInCampaignEvent extends ProductsScreenEvent {
  final bool? isParticipatesInCampaign;
  const ToggleParticipatesInCampaignEvent(this.isParticipatesInCampaign);

  @override
  List<Object?> get props => [isParticipatesInCampaign];
}

class ToggleDeliveryPossibleEvent extends ProductsScreenEvent {
  final bool? isDeliveryPossible;
  const ToggleDeliveryPossibleEvent(this.isDeliveryPossible);

  @override
  List<Object?> get props => [isDeliveryPossible];
}

class ClearEvent extends ProductsScreenEvent {
  const ClearEvent();

  @override
  List<Object> get props => [];
}

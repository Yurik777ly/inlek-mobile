part of 'product_filter_bloc.dart';

abstract class ProductFilterEvent extends Equatable {
  const ProductFilterEvent();

  @override
  List<Object?> get props => [];
}

class ChangePriceEvent extends ProductFilterEvent {
  final double? newPrice;
  final bool? isMinPrice;
  const ChangePriceEvent(this.newPrice, this.isMinPrice);

  @override
  List<Object?> get props => [newPrice, isMinPrice ?? false];
}

class SelectReleaseFormEvent extends ProductFilterEvent {
  final String releaseForm;
  final bool? isChecked;
  const SelectReleaseFormEvent(this.releaseForm, this.isChecked);

  @override
  List<Object> get props => [releaseForm, isChecked ?? false];
}

class SelectManufacturerEvent extends ProductFilterEvent {
  final String manufacturer;
  final bool? isChecked;
  const SelectManufacturerEvent(this.manufacturer, this.isChecked);

  @override
  List<Object> get props => [manufacturer, isChecked ?? false];
}

class SelectCountryEvent extends ProductFilterEvent {
  final String country;
  final bool? isChecked;
  const SelectCountryEvent(this.country, this.isChecked);

  @override
  List<Object> get props => [country, isChecked ?? false];
}

class ToggleWithoutPrescriptionEvent extends ProductFilterEvent {
  final bool? isWithoutPrescription;
  const ToggleWithoutPrescriptionEvent(this.isWithoutPrescription);

  @override
  List<Object?> get props => [isWithoutPrescription];
}

class ToggleParticipatesInCampaignEvent extends ProductFilterEvent {
  final bool? isParticipatesInCampaign;
  const ToggleParticipatesInCampaignEvent(this.isParticipatesInCampaign);

  @override
  List<Object?> get props => [isParticipatesInCampaign];
}

class ToggleDeliveryPossibleEvent extends ProductFilterEvent {
  final bool? isDeliveryPossible;
  const ToggleDeliveryPossibleEvent(this.isDeliveryPossible);

  @override
  List<Object?> get props => [isDeliveryPossible];
}

class ClearEvent extends ProductFilterEvent {
  const ClearEvent();

  @override
  List<Object> get props => [];
}

class LoadFilterDataEvent extends ProductFilterEvent {
  final int categoryId;
  const LoadFilterDataEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

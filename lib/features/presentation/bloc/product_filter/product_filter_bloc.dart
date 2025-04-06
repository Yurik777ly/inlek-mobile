import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/features/domain/usecases/category/get_brands.dart';
import 'package:inlek/features/domain/usecases/category/get_countries.dart';
import 'package:inlek/features/domain/usecases/category/get_forms.dart';

part 'product_filter_event.dart';
part 'product_filter_state.dart';

class ProductFilterBloc extends Bloc<ProductFilterEvent, ProductFilterState> {
  final GetBrandsUC getBrandsUC;
  final GetFormsUC getFormsUC;
  final GetCountriesUC getCountriesUC;

  TextEditingController minValueController = TextEditingController();
  TextEditingController maxValueController = TextEditingController();

  ProductFilterBloc(
      {required this.getBrandsUC,
      required this.getCountriesUC,
      required this.getFormsUC})
      : super(
          ProductFilterState(),
        ) {
    on<ChangePriceEvent>(_onChangePrice);
    on<SelectReleaseFormEvent>(_onSelectReleaseForm);
    on<SelectManufacturerEvent>(_onSelectManufacturer);
    on<SelectCountryEvent>(_onSelectCountry);
    on<ToggleWithoutPrescriptionEvent>(_onToggleWithoutPrescription);
    on<ToggleParticipatesInCampaignEvent>(_onToggleParticipatesInCampaign);
    on<ToggleDeliveryPossibleEvent>(_onToggleDeliveryPossible);
    on<ClearEvent>(_onClear);
    on<LoadFilterDataEvent>(_onLoadFilterData);

    minValueController.text = '0';
    maxValueController.text = '50';
  }

  void _onChangePrice(
      ChangePriceEvent event, Emitter<ProductFilterState> emit) {
    if (event.newPrice == null) return;

    // Ограничиваем цену в рамках допустимых значений
    final clampedPrice =
        event.newPrice!.clamp(state.minAllowedPrice, state.maxAllowedPrice);

    if (event.isMinPrice == true) {
      minValueController.text = clampedPrice.round().toString();
      emit(state.copyWith(minSelectedPrice: clampedPrice));
    } else {
      maxValueController.text = clampedPrice.round().toString();
      emit(state.copyWith(maxSelectedPrice: clampedPrice));
    }
  }

  void _onSelectReleaseForm(
      SelectReleaseFormEvent event, Emitter<ProductFilterState> emit) {
    final updatedReleaseForms = Set<String>.from(state.selectedReleaseForms);
    if (event.isChecked == true) {
      updatedReleaseForms.add(event.releaseForm);
    } else {
      updatedReleaseForms.remove(event.releaseForm);
    }
    emit(state.copyWith(selectedReleaseForms: updatedReleaseForms));
  }

  void _onSelectManufacturer(
      SelectManufacturerEvent event, Emitter<ProductFilterState> emit) {
    final updatedManufacturers = Set<String>.from(state.selectedManufacturers);
    if (event.isChecked == true) {
      updatedManufacturers.add(event.manufacturer);
    } else {
      updatedManufacturers.remove(event.manufacturer);
    }
    emit(state.copyWith(selectedManufacturers: updatedManufacturers));
  }

  void _onSelectCountry(
      SelectCountryEvent event, Emitter<ProductFilterState> emit) {
    final updatedCountries = Set<String>.from(state.selectedCountries);
    if (event.isChecked == true) {
      updatedCountries.add(event.country);
    } else {
      updatedCountries.remove(event.country);
    }
    emit(state.copyWith(selectedCountries: updatedCountries));
  }

  void _onToggleWithoutPrescription(
      ToggleWithoutPrescriptionEvent event, Emitter<ProductFilterState> emit) {
    emit(state.copyWith(isWithoutPrescription: event.isWithoutPrescription));
  }

  void _onToggleParticipatesInCampaign(ToggleParticipatesInCampaignEvent event,
      Emitter<ProductFilterState> emit) {
    emit(state.copyWith(
        isParticipatesInCampaign: event.isParticipatesInCampaign));
  }

  void _onToggleDeliveryPossible(
      ToggleDeliveryPossibleEvent event, Emitter<ProductFilterState> emit) {
    emit(state.copyWith(isDeliveryPossible: event.isDeliveryPossible));
  }

  void _onClear(ClearEvent event, Emitter<ProductFilterState> emit) {
    minValueController.text = '0';
    maxValueController.text = '50';
    emit(
      state.copyWith(
          selectedCountries: {},
          selectedManufacturers: {},
          selectedReleaseForms: {},
          isDeliveryPossible: false,
          isParticipatesInCampaign: false,
          isWithoutPrescription: false,
          minSelectedPrice: 0,
          maxSelectedPrice: 50),
    );
  }

  void _onLoadFilterData(
      LoadFilterDataEvent event, Emitter<ProductFilterState> emit) async {
    List<String> brands = [];
    List<String> countries = [];
    List<String> forms = [];

    var data = await Future.wait(
      [
        getBrandsUC(event.categoryId),
        getCountriesUC(event.categoryId),
        getFormsUC(event.categoryId),
      ],
    );

    data.forEachIndexed(
      (index, element) {
        element.fold(
          (_) {},
          (result) => switch (index) {
            0 => brands = result,
            1 => countries = result,
            2 => forms = result,
            _ => {},
          },
        );
      },
    );

    emit(state.copyWith(
      minAllowedPrice: 0,
      maxAllowedPrice: 50,
      minSelectedPrice: 0,
      maxSelectedPrice: 50,
      releaseForms: forms,
      selectedReleaseForms: {},
      manufacturers: brands,
      selectedManufacturers: {},
      countries: countries,
      selectedCountries: {},
      isWithoutPrescription: false,
      isParticipatesInCampaign: false,
      isDeliveryPossible: false,
    ));
  }

  @override
  Future<void> close() {
    // Clean up the controller and focus node when the bloc is closed
    minValueController.dispose();
    maxValueController.dispose();

    return super.close();
  }
}

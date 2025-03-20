import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/core/models/product_json_model.dart';

part 'search_screen_event.dart';
part 'search_screen_state.dart';

class SearchScreenBloc extends Bloc<SearchScreenEvent, SearchScreenState> {
  TextEditingController searchController = TextEditingController();
  TextEditingController minValueController = TextEditingController();
  TextEditingController maxValueController = TextEditingController();

  FocusNode focusNode = FocusNode();

  SearchScreenBloc()
      : super(
          SearchScreenState(
            minAllowedPrice: 0,
            maxAllowedPrice: 50,
            minSelectedPrice: 0,
            maxSelectedPrice: 50,
            releaseForms: [],
            selectedReleaseFormsId: {},
            manufacturers: [],
            selectedManufacturersId: {},
            countries: [],
            selectedCountriesId: {},
            isWithoutPrescription: false,
            isParticipatesInCampaign: false,
            isDeliveryPossible: false,
            isExpanded: false,
            query: '',
            suggestions: [],
          ),
        ) {
    on<LoadDataEvent>(_onLoadData);
    on<ChangePriceEvent>(_onChangePrice);
    on<SelectReleaseFormEvent>(_onSelectReleaseForm);
    on<SelectManufacturerEvent>(_onSelectManufacturer);
    on<SelectCountryEvent>(_onSelectCountry);
    on<ToggleWithoutPrescriptionEvent>(_onToggleWithoutPrescription);
    on<ToggleParticipatesInCampaignEvent>(_onToggleParticipatesInCampaign);
    on<ToggleDeliveryPossibleEvent>(_onToggleDeliveryPossible);
    on<ClearEvent>(_onClear);
    on<ToggleExpandCollapseEvent>(_onToggleExpandCollapse);
    on<ClearQueryEvent>(_onClearQuery);
    on<ChangeQueryEvent>(_onChangeQuery);
    on<SelectSuggestionsEvent>(_onSelectSuggestions);

    minValueController.text = '0';
    maxValueController.text = '50';
  }

  Future _onLoadData(
      LoadDataEvent event, Emitter<SearchScreenState> emit) async {
    String jsonString =
        await rootBundle.loadString(Paths.searchProductJsonPath);

    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    final List<dynamic> productsJson = jsonData['data']['products'];

    List<ProductJsonModel> products =
        productsJson.map((json) => ProductJsonModel.fromJson(json)).toList();

    Set<String> countries = products
        .map((e) => e.properties?.country?.value)
        .whereType<String>()
        .toSet();

    Set<String> releaseForm = products
        .map((e) => e.properties?.releaseForm?.value)
        .whereType<String>()
        .toSet();

    Set<String> brand = products
        .map((e) => e.properties?.brand?.value)
        .whereType<String>()
        .toSet();

    Set<String> suggestions =
        products.map((e) => e.title).whereType<String>().toSet();

    double maxPrice = products
            .map((e) => e.price)
            .reduce((a, b) => (a ?? 0) > (b ?? 0) ? a : b) ??
        0;

    minValueController.text = '0';
    maxValueController.text = maxPrice.round().toString();

    emit(
      state.copyWith(
          countries: countries.toList(),
          releaseForms: releaseForm.toList(),
          manufacturers: brand.toList(),
          suggestions: suggestions.toList(),
          minAllowedPrice: 0,
          maxAllowedPrice: maxPrice,
          minSelectedPrice: 0,
          maxSelectedPrice: maxPrice),
    );
  }

  void _onChangeQuery(ChangeQueryEvent event, Emitter<SearchScreenState> emit) {
    emit(state.copyWith(query: event.text));
  }

  void _onSelectSuggestions(
      SelectSuggestionsEvent event, Emitter<SearchScreenState> emit) {
    searchController.clear();
    emit(state.copyWith(isExpanded: false, query: ''));
  }

  void _onClearQuery(ClearQueryEvent event, Emitter<SearchScreenState> emit) {
    searchController.clear();
    emit(state.copyWith(isExpanded: false, query: ''));
  }

  void _onToggleExpandCollapse(
      ToggleExpandCollapseEvent event, Emitter<SearchScreenState> emit) {
    emit(state.copyWith(isExpanded: event.isExpanded));
  }

  void _onChangePrice(ChangePriceEvent event, Emitter<SearchScreenState> emit) {
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
      SelectReleaseFormEvent event, Emitter<SearchScreenState> emit) {
    final updatedReleaseForms = Set<int>.from(state.selectedReleaseFormsId);
    if (event.isChecked == true) {
      updatedReleaseForms.add(event.releaseFormId);
    } else {
      updatedReleaseForms.remove(event.releaseFormId);
    }
    emit(state.copyWith(selectedReleaseFormsId: updatedReleaseForms));
  }

  void _onSelectManufacturer(
      SelectManufacturerEvent event, Emitter<SearchScreenState> emit) {
    final updatedManufacturers = Set<int>.from(state.selectedManufacturersId);
    if (event.isChecked == true) {
      updatedManufacturers.add(event.manufacturerId);
    } else {
      updatedManufacturers.remove(event.manufacturerId);
    }
    emit(state.copyWith(selectedManufacturersId: updatedManufacturers));
  }

  void _onSelectCountry(
      SelectCountryEvent event, Emitter<SearchScreenState> emit) {
    final updatedCountries = Set<int>.from(state.selectedCountriesId);
    if (event.isChecked == true) {
      updatedCountries.add(event.countryId);
    } else {
      updatedCountries.remove(event.countryId);
    }
    emit(state.copyWith(selectedCountriesId: updatedCountries));
  }

  void _onToggleWithoutPrescription(
      ToggleWithoutPrescriptionEvent event, Emitter<SearchScreenState> emit) {
    emit(state.copyWith(isWithoutPrescription: event.isWithoutPrescription));
  }

  void _onToggleParticipatesInCampaign(ToggleParticipatesInCampaignEvent event,
      Emitter<SearchScreenState> emit) {
    emit(state.copyWith(
        isParticipatesInCampaign: event.isParticipatesInCampaign));
  }

  void _onToggleDeliveryPossible(
      ToggleDeliveryPossibleEvent event, Emitter<SearchScreenState> emit) {
    emit(state.copyWith(isDeliveryPossible: event.isDeliveryPossible));
  }

  void _onClear(ClearEvent event, Emitter<SearchScreenState> emit) {
    minValueController.text = '0';
    maxValueController.text = state.maxAllowedPrice.round().toString();
    emit(
      state.copyWith(
          selectedCountriesId: {},
          selectedManufacturersId: {},
          selectedReleaseFormsId: {},
          isDeliveryPossible: false,
          isParticipatesInCampaign: false,
          isWithoutPrescription: false,
          minSelectedPrice: 0,
          maxSelectedPrice: state.maxAllowedPrice),
    );
  }

  @override
  Future<void> close() {
    // Clean up the controller and focus node when the bloc is closed
    minValueController.dispose();
    maxValueController.dispose();

    return super.close();
  }
}

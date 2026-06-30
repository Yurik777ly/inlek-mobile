import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/core/geocoder_manager.dart';
import 'package:inlek/core/location_manager.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/city_model.dart';
import 'package:inlek/features/domain/entities/city_entity.dart';
import 'package:inlek/features/domain/usecases/content/get_cities.dart';
import 'package:inlek/locator_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

part 'select_region_screen_event.dart';
part 'select_region_screen_state.dart';

class SelectRegionScreenBloc
    extends Bloc<SelectRegionScreenEvent, SelectRegionScreenState> {
  final GetCitiesUC getCitiesUC;
  final SharedPreferences sharedPreferences;

  final TextEditingController regionController = TextEditingController();

  SelectRegionScreenBloc(
      {required this.getCitiesUC, required this.sharedPreferences})
      : super(
          SelectRegionScreenState(),
        ) {
    on<LoadDataEvent>(_onLoadData);
    on<RegionChangedEvent>(_onRegionChanged);
    on<ConfirmRegionEvent>(_onConfirmRegion);
    on<DetectCurrentCityEvent>(_onDetectCurrentCity);

    regionController.addListener(() {
      add(RegionChangedEvent(regionController.text));
    });
  }

  String _normalizeCityName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceFirst(RegExp(r'^г\.?\s*'), '');
  }

  CityEntity? _findCityByInput(String input, List<CityEntity> cities) {
    final normalized = _normalizeCityName(input);
    if (normalized.isEmpty) {
      return null;
    }

    return cities.firstWhereOrNull(
      (city) =>
          _normalizeCityName(city.pagetitle) == normalized ||
          city.alias.toLowerCase() == normalized,
    );
  }

  CityEntity? _findCityByGeocodeName(String name, List<CityEntity> cities) {
    final exactMatch = _findCityByInput(name, cities);
    if (exactMatch != null) {
      return exactMatch;
    }

    final normalized = _normalizeCityName(name);
    if (normalized.isEmpty) {
      return null;
    }

    return cities.firstWhereOrNull((city) {
      final cityName = _normalizeCityName(city.pagetitle);
      return cityName.contains(normalized) || normalized.contains(cityName);
    });
  }

  String? _extractCityNameFromGeocode(GeocodeResponse? response) {
    final geoObject = response
        ?.response?.geoObjectCollection?.featureMember?.firstOrNull?.geoObject;
    if (geoObject == null) {
      return null;
    }

    final components =
        geoObject.metaDataProperty?.geocoderMetaData?.address?.components ?? [];

    for (final kind in [
      KindResponse.locality,
      KindResponse.district,
      KindResponse.area,
    ]) {
      final name = components.firstWhereOrNull((c) => c.kind == kind)?.name;
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }

    final formatted =
        geoObject.metaDataProperty?.geocoderMetaData?.address?.formatted;
    if (formatted != null && formatted.isNotEmpty) {
      return formatted.split(',').first.trim();
    }

    return null;
  }

  void _applyDetectedCity(
    Emitter<SelectRegionScreenState> emit,
    String cityName,
  ) {
    final matchedCity = _findCityByGeocodeName(cityName, state.popularCities);
    if (matchedCity != null) {
      regionController.text = matchedCity.pagetitle;
      emit(state.copyWith(
        detectedCity: matchedCity.pagetitle,
        selectedRegion: matchedCity,
        isButtonActive: true,
        showError: false,
      ));
      return;
    }

    emit(state.copyWith(detectedCity: cityName));
  }

  bool _isPrefixOfKnownCity(String input, List<CityEntity> cities) {
    final normalized = _normalizeCityName(input);
    if (normalized.isEmpty) {
      return false;
    }

    return cities.any(
      (city) => _normalizeCityName(city.pagetitle).startsWith(normalized),
    );
  }

  Future<void> _onDetectCurrentCity(DetectCurrentCityEvent event,
      Emitter<SelectRegionScreenState> emit) async {
    final position = await LocationManager.determinePosition();
    if (position == null) {
      _applyDetectedCity(emit, 'Минск');
      return;
    }

    final geocoderManager = sl<GeocoderManager>();
    final response = await geocoderManager.getGeocodeFromPoint(
      position.latitude,
      position.longitude,
    );
    final city = _extractCityNameFromGeocode(response) ?? 'Минск';
    _applyDetectedCity(emit, city);
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<SelectRegionScreenState> emit) async {
    final failureOrLoads = await getCitiesUC();

    failureOrLoads.fold(
      (_) => emit(state.copyWith(showError: false)),
      (cities) {
        final publishedCities =
            cities.where((city) => city.published).toList();
        emit(state.copyWith(showError: false, popularCities: publishedCities));
        add(DetectCurrentCityEvent());
      },
    );
  }

  void _onRegionChanged(
    RegionChangedEvent event,
    Emitter<SelectRegionScreenState> emit,
  ) async {
    final input = regionController.text;
    final selectedRegion = _findCityByInput(input, state.popularCities);
    final isKnownRegion = selectedRegion != null;

    final shouldShowError = input.trim().isNotEmpty &&
        selectedRegion == null &&
        !_isPrefixOfKnownCity(input, state.popularCities);

    emit(
      state.copyWith(
        isButtonActive: isKnownRegion,
        selectedRegion: selectedRegion,
        showError: shouldShowError,
      ),
    );
  }

  void _onConfirmRegion(
      ConfirmRegionEvent event, Emitter<SelectRegionScreenState> emit) async {
    final selectedRegion =
        _findCityByInput(regionController.text, state.popularCities);
    if (selectedRegion == null) {
      return;
    }

    sharedPreferences.setString(
      SharedPreferencesKeys.city,
      jsonEncode((selectedRegion as CityModel).toJson()),
    );
  }

  @override
  Future<void> close() {
    regionController.dispose();
    return super.close();
  }
}

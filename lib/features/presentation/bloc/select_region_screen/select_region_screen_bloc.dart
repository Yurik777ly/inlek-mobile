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
      emit(state.copyWith(detectedCity: null));
      return;
    }
    final geocoderManager = sl<GeocoderManager>();
    final response = await geocoderManager.getGeocodeFromPoint(
        position.latitude, position.longitude);
    final geoObject =
        response?.response?.geoObjectCollection?.featureMember?.first.geoObject;
    String? city;
    try {
      final components =
          geoObject?.metaDataProperty?.geocoderMetaData?.address?.components;
      city = null;
      if (components != null) {
        for (final c in components) {
          if (c.kind == KindResponse.locality) {
            city = c.name;
            break;
          }
        }
        if (city == null) {
          for (final c in components) {
            if (c.kind == KindResponse.area) {
              city = c.name;
              break;
            }
          }
        }
      }
    } catch (_) {
      city = null;
    }
    if (city == null) {
      city = 'Минск';
    }

    final matchedCity = _findCityByInput(city, state.popularCities);
    if (matchedCity != null) {
      regionController.text = matchedCity.pagetitle;
      emit(state.copyWith(
        detectedCity: city,
        selectedRegion: matchedCity,
        isButtonActive: true,
        showError: false,
      ));
    } else {
      emit(state.copyWith(detectedCity: city));
    }
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<SelectRegionScreenState> emit) async {
    final failureOrLoads = await getCitiesUC();

    failureOrLoads.fold(
      (_) => emit(state.copyWith(showError: false)),
      (cities) {
        emit(state.copyWith(showError: false, popularCities: cities));
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

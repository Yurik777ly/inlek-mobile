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
      emit(state.copyWith(detectedCity: 'Минск'));
      return;
    }
    if (state.popularCities.contains(city)) {
      regionController.text = city;
      emit(state.copyWith(
        detectedCity: city,
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
      (_) => emit(state.copyWith(showError: true)),
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
    final selectedRegion = state.popularCities.firstWhereOrNull(
      (city) => city.pagetitle == event.region,
    );

    final isKnownRegion = state.popularCities
        .any((city) => city.pagetitle == regionController.text);

    final shouldShowError =
        selectedRegion == null && regionController.text.isNotEmpty;

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
    final selectedRegion = state.popularCities
        .firstWhereOrNull((city) => city.pagetitle == regionController.text);

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

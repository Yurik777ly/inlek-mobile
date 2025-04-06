import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/usecases/content/get_cities.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    regionController.addListener(() {
      add(RegionChangedEvent(regionController.text));
    });
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<SelectRegionScreenState> emit) async {
    final failureOrLoads = await getCitiesUC();

    failureOrLoads.fold(
      (_) => emit(state.copyWith(showError: true)),
      (cities) => emit(state.copyWith(showError: false, popularCities: cities)),
    );
  }

  void _onRegionChanged(
      RegionChangedEvent event, Emitter<SelectRegionScreenState> emit) async {
    emit(
      state.copyWith(
          isButtonActive: state.popularCities.contains(regionController.text),
          showError: !state.popularCities.contains(event.region) &&
              regionController.text.isNotEmpty),
    );
  }

  void _onConfirmRegion(
      ConfirmRegionEvent event, Emitter<SelectRegionScreenState> emit) async {
    sharedPreferences.setString(
        SharedPreferencesKeys.city, regionController.text);
  }

  @override
  Future<void> close() {
    regionController.dispose();
    return super.close();
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

part 'pharmacies_screen_event.dart';
part 'pharmacies_screen_state.dart';

class PharmaciesScreenBloc
    extends Bloc<PharmaciesScreenEvent, PharmaciesScreenState> {
  final TextEditingController queryController = TextEditingController();

  PharmaciesScreenBloc() : super(PharmaciesScreenState()) {
    on<ChangeSelectorIndexEvent>((event, emit) {
      emit(state.copyWith(selectorIndex: event.selectorIndex));
    });

    on<ChangePharmacySortTypeEvent>((event, emit) {
      emit(state.copyWith(pharmacySortType: event.pharmacySortType));
      _filterAndEmit(emit);
    });

    on<ChangePharmacyQueryEvent>((event, emit) {
      emit(state.copyWith(query: event.query));
      _filterAndEmit(emit);
    });

    on<LoadPharmaciesDataEvent>((event, emit) {
      emit(state.copyWith(
        pharmacies: event.pharmacies,
        filteredPharmacies: event.pharmacies,
        mapObjects: _generateMapObjects(event.pharmacies),
      ));
    });
  }

  void _filterAndEmit(Emitter<PharmaciesScreenState> emit) {
    final filteredPharmacies = _filterPharmacies(
        state.pharmacies, state.query, state.pharmacySortType);

    emit(
      state.copyWith(
        filteredPharmacies: filteredPharmacies,
        mapObjects: _generateMapObjects(filteredPharmacies),
      ),
    );
  }

  List<PharmacyEntity> _filterPharmacies(
    List<PharmacyEntity> pharmacies,
    String query,
    TypeReceiving sortType,
  ) {
    final lowerQuery = query.toLowerCase();
    return pharmacies.where((e) {
      final isMatchingQuery = (e.pharmacyName ?? e.pageTitle ?? '')
          .toLowerCase()
          .contains(lowerQuery);
      final isMatchingSortType = sortType == TypeReceiving.all ||
          e.pharmacyDelivery ==
              (sortType == TypeReceiving.delivery ? 'Доставка' : 'Самовывоз');

      return isMatchingQuery && isMatchingSortType;
    }).toList();
  }

  List<CustomMapObject> _generateMapObjects(List<PharmacyEntity> pharmacies) {
    return pharmacies
        .map((pharmacy) {
          final coords = pharmacy.coordinates?.split(', ');
          if (coords == null || coords.length < 2) return null;

          final latitude = double.tryParse(coords[0]);
          final longitude = double.tryParse(coords[1]);
          if (latitude == null || longitude == null) return null;

          return CustomMapObject(
            mapObject: PlacemarkMapObject(
              mapId: MapObjectId(pharmacy.pharmacyId.toString()),
              point: Point(latitude: latitude, longitude: longitude),
            ),
            data: (pharmacy as PharmacyModel).toJson(),
          );
        })
        .whereType<CustomMapObject>()
        .toList();
  }
}

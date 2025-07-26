import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

part 'pharmacies_screen_event.dart';
part 'pharmacies_screen_state.dart';

class PharmaciesScreenBloc
    extends Bloc<PharmaciesScreenEvent, PharmaciesScreenState> {
  final ProductEntity? product;

  final TextEditingController queryController = TextEditingController();

  PharmaciesScreenBloc({this.product}) : super(PharmaciesScreenState()) {
    on<CheckProductAvailableDeliveryEvent>((event, emit) {
      bool isRestrictedProduct = product!.isRecipe || product!.isAlcohol;
      if (isRestrictedProduct) {
        emit(state.copyWith(pharmacySortType: TypeReceiving.pickup));
      }
    });

    on<LoadPharmaciesDataEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, hasError: false));

      if (event.pharmacies != null) {
        emit(
          state.copyWith(
            isLoading: false,
            hasError: false,
            pharmacies: event.pharmacies,
            filteredPharmacies: event.pharmacies,
            mapObjects: _generateMapObjects(event.pharmacies ?? []),
          ),
        );
      }
    });

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
      List<PharmacyEntity> pharmacies, String query, TypeReceiving sortType) {
    final lowerQuery = query.toLowerCase();

    return pharmacies.where((e) {
      final hasEnoughQuery = lowerQuery.length <
              3 || // фильтрация по названию включается с 3 символов
          (e.address ?? '').toLowerCase().contains(lowerQuery);

      final isMatchingSortType = sortType == TypeReceiving.all ||
          e.availability ==
              (sortType == TypeReceiving.delivery ? 'Доставка' : 'Самовывоз');

      return hasEnoughQuery && isMatchingSortType;
    }).toList();
  }

  List<CustomMapObject> _generateMapObjects(List<PharmacyEntity> pharmacies) {
    return pharmacies
        .map((pharmacy) {
          final coords = pharmacy.coordinates.split(', ');
          if (coords.length < 2) return null;

          final latitude = double.tryParse(coords[0]);
          final longitude = double.tryParse(coords[1]);
          if (latitude == null || longitude == null) return null;

          return CustomMapObject(
            mapObject: PlacemarkMapObject(
              mapId: MapObjectId(pharmacy.pharmacyId.toString()),
              point: Point(latitude: latitude, longitude: longitude),
            ),
            data: pharmacy.toJson(),
          );
        })
        .whereType<CustomMapObject>()
        .toList();
  }
}

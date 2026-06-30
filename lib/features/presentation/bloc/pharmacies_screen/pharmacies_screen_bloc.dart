import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/ui_constants.dart';
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
      _applyFilters(
        emit,
        state.copyWith(pharmacySortType: event.pharmacySortType),
      );
    });

    on<ChangePharmacyQueryEvent>((event, emit) {
      _applyFilters(emit, state.copyWith(query: event.query));
    });
  }

  void _applyFilters(
    Emitter<PharmaciesScreenState> emit,
    PharmaciesScreenState nextState,
  ) {
    final filteredPharmacies = _filterPharmacies(nextState);

    emit(
      nextState.copyWith(
        filteredPharmacies: filteredPharmacies,
        mapObjects: _generateMapObjects(filteredPharmacies),
      ),
    );
  }

  bool _matchesReceivingType(PharmacyEntity pharmacy, TypeReceiving sortType) {
    switch (sortType) {
      case TypeReceiving.all:
        return true;
      case TypeReceiving.pickup:
        return pharmacy.pharmacyId != UiConstants.deliveryPharmacyId;
      case TypeReceiving.delivery:
        return pharmacy.pharmacyId == UiConstants.deliveryPharmacyId;
    }
  }

  List<PharmacyEntity> _filterPharmacies(PharmaciesScreenState filterState) {
    final lowerQuery = filterState.query.toLowerCase();

    return filterState.pharmacies.where((pharmacy) {
      final hasEnoughQuery = lowerQuery.length < 3 ||
          pharmacy.address.toLowerCase().contains(lowerQuery);

      return hasEnoughQuery &&
          _matchesReceivingType(pharmacy, filterState.pharmacySortType);
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

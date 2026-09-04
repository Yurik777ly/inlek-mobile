import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/pharmacy_utils.dart';
import 'package:inlek/core/location_manager.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/core/params/cart_pharmacies_param.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';
import 'package:inlek/features/domain/usecases/cart/get_cart_pharmacies.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

part 'pharmacies_cart_screen_event.dart';
part 'pharmacies_cart_screen_state.dart';

class PharmaciesCartScreenBloc
    extends Bloc<PharmaciesCartScreenEvent, PharmaciesCartScreenState> {
  final BuildContext? context;

  final GetCartPharmaciesUC getCartPharmaciesUC;
  final TextEditingController queryController = TextEditingController();

  PharmaciesCartScreenBloc({required this.getCartPharmaciesUC, this.context})
      : super(PharmaciesCartScreenState()) {
    on<ChangeSelectorIndexEvent>((event, emit) {
      emit(state.copyWith(selectorIndex: event.selectorIndex));
    });

    on<ChangePharmacyCartQueryEvent>((event, emit) {
      _applyFilters(
        emit,
        state.copyWith(query: event.query),
      );
    });

    on<ToggleShowWorkingNowOnlyEvent>((event, emit) {
      _applyFilters(
        emit,
        state.copyWith(showWorkingNowOnly: event.value),
      );
    });

    on<ToggleShowWithAllProductsOnlyEvent>((event, emit) {
      _applyFilters(
        emit,
        state.copyWith(showWithAllProductsOnly: event.value),
      );
    });

    on<LoadPharmaciesCartDataEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, hasError: false));

      try {
        final position = await LocationManager.determinePosition(
          requestIfDenied: false,
        );

        final param = CartPharmaciesParam(
          geoLat: position?.latitude ?? 0.0,
          geoLong: position?.longitude ?? 0.0,
          products: event.products,
        );
        final failureOrLoads = await getCartPharmaciesUC(param);

        failureOrLoads.fold(
          (_) => _applyFilters(
            emit,
            state.copyWith(isLoading: false, hasError: true),
          ),
          (pharmacies) => _applyFilters(
            emit,
            state.copyWith(
              isLoading: false,
              hasError: false,
              pharmacies: pharmacies,
            ),
          ),
        );
      } catch (_) {
        _applyFilters(
          emit,
          state.copyWith(isLoading: false, hasError: true),
        );
      }
    });
  }

  void _applyFilters(
    Emitter<PharmaciesCartScreenState> emit,
    PharmaciesCartScreenState nextState,
  ) {
    final filteredPharmacies = _filterPharmacies(nextState);
    final mapPharmacies = _filterPharmacies(
      nextState.copyWith(query: ''),
    );

    emit(
      nextState.copyWith(
        filteredPharmacies: filteredPharmacies,
        mapObjects: _generateMapObjects(mapPharmacies),
      ),
    );
  }

  List<CartPharmacyEntity> _filterPharmacies(
    PharmaciesCartScreenState filterState,
  ) {
    final lowerQuery = filterState.query.toLowerCase();

    return filterState.pharmacies.where((pharmacy) {
      // Аптеки без наличия выбранных товаров не показываем для самовывоза.
      if (pharmacy.availability == 'absent') {
        return false;
      }

      final hasEnoughQuery = lowerQuery.length < 3 ||
          (pharmacy.address).toLowerCase().contains(lowerQuery);

      final isMatchingSortType = filterState.pharmacySortType ==
              TypeReceiving.all ||
          pharmacy.availability ==
              (filterState.pharmacySortType == TypeReceiving.delivery
                  ? 'Доставка'
                  : 'Самовывоз');

      final isWorkingNow = !filterState.showWorkingNowOnly ||
          PharmacyUtils.isPharmacyOpen(pharmacy.schedule);

      final allProductsAvailable = !filterState.showWithAllProductsOnly ||
          pharmacy.availability == 'full';

      return hasEnoughQuery &&
          isMatchingSortType &&
          isWorkingNow &&
          allProductsAvailable;
    }).toList();
  }

  List<CustomMapObject> _generateMapObjects(
      List<CartPharmacyEntity> pharmacies) {
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

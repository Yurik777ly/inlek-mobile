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
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
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
      emit(state.copyWith(query: event.query));
      _filterAndEmit(emit);
    });

    on<ToggleShowWorkingNowOnlyEvent>((event, emit) {
      emit(state.copyWith(showWorkingNowOnly: event.value));
      _filterAndEmit(emit);
    });

    on<ToggleShowWithAllProductsOnlyEvent>((event, emit) {
      emit(state.copyWith(showWithAllProductsOnly: event.value));
      _filterAndEmit(emit);
    });

    on<LoadPharmaciesCartDataEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, hasError: false));

      final position = await LocationManager.determinePosition();

      // Формируем param для запроса
      final param = CartPharmaciesParam(
          geoLat: position?.latitude ?? 0.0,
          geoLong: position?.longitude ?? 0.0,
          products: event.products);
      final failureOrLoads = await getCartPharmaciesUC(param);

      failureOrLoads.fold(
        (_) {
          emit(state.copyWith(isLoading: false, hasError: true));
          _filterAndEmit(emit);
        },
        (pharmacies) => emit(
          state.copyWith(
            isLoading: false,
            hasError: false,
            pharmacies: pharmacies,
            filteredPharmacies: pharmacies,
            mapObjects: _generateMapObjects(pharmacies),
          ),
        ),
      );
    });
  }

  void _filterAndEmit(Emitter<PharmaciesCartScreenState> emit) {
    final filteredPharmacies = _filterPharmacies(
        state.pharmacies, state.query, state.pharmacySortType);

    emit(
      state.copyWith(
        filteredPharmacies: filteredPharmacies,
        mapObjects: _generateMapObjects(filteredPharmacies),
      ),
    );
  }

  List<CartPharmacyEntity> _filterPharmacies(
      List<CartPharmacyEntity> pharmacies,
      String query,
      TypeReceiving sortType) {
    Set<int> selectedProductIds =
        context?.read<CartScreenBloc>().state.selectedProductIds ?? {};

    final lowerQuery = query.toLowerCase();

    return pharmacies.where((e) {
      final hasEnoughQuery = lowerQuery.length <
              3 || // фильтрация по названию включается с 3 символов
          (e.address ?? '').toLowerCase().contains(lowerQuery);

      final isMatchingSortType = sortType == TypeReceiving.all ||
          e.availability ==
              (sortType == TypeReceiving.delivery ? 'Доставка' : 'Самовывоз');

      final isWorkingNow = !state.showWorkingNowOnly ||
          PharmacyUtils.isPharmacyOpen(e.schedule ?? '');

      final bool allSelectedProductsExist = selectedProductIds.every(
        (id) => e.products.any((product) => product.productId == id),
      );

      final filteredProducts = e.products
          .where((product) => selectedProductIds.contains(product.productId))
          .toList();

      final bool allAvailable = filteredProducts.every(
        (product) => product.availability == 'full',
      );

      final bool allProductsAvailable =
          (allSelectedProductsExist && allAvailable) ||
              !state.showWithAllProductsOnly;

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

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/core/location_manager.dart';
import 'package:inlek/core/params/product_pharmacies_param.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/usecases/products/get_one_product.dart';
import 'package:inlek/features/domain/usecases/products/get_product_pharmacies.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'product_screen_event.dart';
part 'product_screen_state.dart';

class ProductScreenBloc extends Bloc<ProductScreenEvent, ProductScreenState> {
  final int? productId;
  final GetOneProductUC getOneProductUC;
  final GetProductPharmaciesUC getProductPharmaciesUC;

  final SharedPreferences sharedPreferences;

  PageController pageController = PageController();

  ProductScreenBloc({
    this.productId,
    required this.getOneProductUC,
    required this.getProductPharmaciesUC,
    required this.sharedPreferences,
  }) : super(ProductScreenState()) {
    on<LoadDataEvent>(_onLoadData);
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<ProductScreenState> emit) async {
    // Начинаем загрузку товара и аптек одновременно
    emit(state.copyWith(isLoadingProducts: true, isLoadingPharmacies: true));

    // Запускаем загрузку товара и аптек параллельно
    await Future.wait([
      _loadProduct(emit),
      _loadPharmacies(emit),
    ]);
  }

  Future<void> _loadProduct(Emitter<ProductScreenState> emit) async {
    if (productId != null) {
      final result = await getOneProductUC(productId!);
      result.fold(
        (failure) {
          emit(state.copyWith(
            isLoadingProducts: false,
            error: 'Ошибка загрузки товара',
          ));
        },
        (product) {
          if (product == null) {
            emit(state.copyWith(
              isLoadingProducts: false,
              product: null,
              error: 'Ошибка загрузки товара',
            ));
          } else {
            emit(state.copyWith(
              isLoadingProducts: false,
              product: product,
              error: null,
            ));
          }
        },
      );
    } else {
      emit(
          state.copyWith(isLoadingProducts: false, isLoadingPharmacies: false));
    }
  }

  Future<void> _loadPharmacies(Emitter<ProductScreenState> emit) async {
    if (productId != null) {
      final position = await LocationManager.determinePosition();

      // Формируем param для запроса
      final param = ProductPharmaciesParam(
          geoLat: position?.latitude ?? 0.0,
          geoLong: position?.longitude ?? 0.0,
          productId: productId!);

      final result = await getProductPharmaciesUC(param);
      result.fold(
        (failure) {
          emit(state.copyWith(
            isLoadingPharmacies: false,
            errorPharmacies: 'Ошибка загрузки аптек',
          ));
        },
        (pharmacies) {
          emit(state.copyWith(
            isLoadingPharmacies: false,
            pharmacies: pharmacies,
            errorPharmacies: null,
          ));
        },
      );
    } else {
      emit(state.copyWith(isLoadingPharmacies: false));
    }
  }
}

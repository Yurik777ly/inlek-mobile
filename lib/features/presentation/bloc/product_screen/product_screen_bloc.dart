import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/core/location_manager.dart';
import 'package:inlek/core/params/product_pharmacies_param.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/city_model.dart';
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
    String? error = 'Ошибка получения данных';
    ProductEntity? product;
    List<PharmacyEntity> pharmacies = [];

    final city = (() {
      try {
        final json = sharedPreferences.getString(SharedPreferencesKeys.city);
        return json == null ? null : CityModel.fromJson(jsonDecode(json));
      } catch (_) {
        return null;
      }
    })();

    if (productId != null) {
      final position = await LocationManager.determinePosition();

      // Формируем param для запроса
      final param = ProductPharmaciesParam(
          geoLat: position?.latitude ?? 0.0,
          geoLong: position?.longitude ?? 0.0,
          productId: productId!);

      var data = await Future.wait(
        [
          getOneProductUC(productId!),
          getProductPharmaciesUC(param),
        ],
      );

      data.forEachIndexed(
        (index, element) {
          element.fold(
            (_) {},
            (result) => switch (index) {
              0 => product = result as ProductEntity,
              1 => pharmacies = result as List<PharmacyEntity>,
              _ => {},
            },
          );
        },
      );

      if (product != null) error = null;
    }

    emit(
      ProductScreenState(
          isLoading: false,
          error: error,
          product: product,
          pharmacies: pharmacies),
    );
  }
}

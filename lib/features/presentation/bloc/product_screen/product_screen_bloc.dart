import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/core/location_manager.dart';
import 'package:inlek/core/params/pharmacies_by_product_params.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/usecases/products/get_one_product.dart';
import 'package:inlek/features/domain/usecases/products/get_product_pharmacies.dart';

part 'product_screen_event.dart';
part 'product_screen_state.dart';

class ProductScreenBloc extends Bloc<ProductScreenEvent, ProductScreenState> {
  final int? productId;
  final GetOneProductUC getOneProductUC;
  final GetProductPharmaciesUC getProductPharmaciesUC;
  final LocationManager locationManager;

  PageController pageController = PageController();

  ProductScreenBloc({
    this.productId,
    required this.getOneProductUC,
    required this.getProductPharmaciesUC,
    required this.locationManager,
  }) : super(ProductScreenState()) {
    on<LoadDataEvent>(_onLoadData);
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<ProductScreenState> emit) async {
    String? error = 'Ошибка получения данных';
    ProductEntity? product;
    List<PharmacyEntity> pharmacies = [];

    if (productId != null) {
      final position = await locationManager.determinePosition();

      final params = PharmaciesByProductParams(
          productId: productId,
          geoLat: position?.latitude,
          geoLong: position?.longitude);

      var data = await Future.wait(
        [
          getOneProductUC(productId!),
          getProductPharmaciesUC(params),
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

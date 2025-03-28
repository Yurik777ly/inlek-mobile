import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/search_products_entity.dart';
import 'package:inlek/features/domain/usecases/products/search_products.dart';

part 'products_screen_event.dart';
part 'products_screen_state.dart';

class ProductsScreenBloc
    extends Bloc<ProductsScreenEvent, ProductsScreenState> {
  final SearchProductsUC searchProductsUC;

  final ProductParam? productParam;
  final List<ProductEntity>? products;

  ScrollController productsController = ScrollController();

  ProductsScreenBloc(
      {required this.searchProductsUC, this.productParam, this.products})
      : super(
          ProductsScreenState(productSortType: ProductSortType.popularity),
        ) {
    on<LoadDataEvent>(_onLoadData);
    on<ChangeProductSortTypeEvent>(_onChangeProductSortTypeEvent);

    // Добавляем слушатель для скролла
    if (products == null) productsController.addListener(_scrollListener);
  }

  void _scrollListener() {
    print("ScrollListener triggered"); // Печатаем, чтобы проверить срабатывание
    // Если скроллинг достиг нижней границы, загружаем следующую страницу
    if (productsController.position.pixels ==
        productsController.position.maxScrollExtent) {
      if (state.searchProducts != null &&
          state.searchProducts!.currentPage < state.searchProducts!.lastPage) {
        // Загружаем следующую страницу
        add(LoadDataEvent(page: state.searchProducts!.currentPage + 1));
      }
    }
  }

  void _onChangeProductSortTypeEvent(
      ChangeProductSortTypeEvent event, Emitter<ProductsScreenState> emit) {
    productsController.animateTo(0,
        duration: Duration(milliseconds: 300), curve: Curves.bounceIn);

    emit(state.copyWith(
        isLoadingProducts: true,
        productSortType: event.productSortType,
        searchProducts: state.searchProducts?.copyWith(products: [])));

    // Повторно вызываем загрузку данных с новым типом сортировки
    add(LoadDataEvent(page: 1));
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<ProductsScreenState> emit) async {
    SearchProductsEntity? searchProducts;
    String? error;

    if (products != null) {
      searchProducts = SearchProductsEntity(
          currentPage: 1,
          lastPage: 1,
          total: (products ?? []).length,
          products: products ?? []);
    }

    if (productParam != null) {
      int currentPage =
          (event.page ?? (state.searchProducts?.currentPage ?? 1));

      List<ProductEntity> oldProducts = [];

      if (currentPage != 1) {
        emit(state.copyWith(isLoadingProducts: true));
        oldProducts = state.searchProducts?.products ?? [];
      }

      final failureOrLoads = await searchProductsUC(
        productParam!.copyWith(
            sortBy: state.productSortType.apiValue,
            page: event.page ?? ((state.searchProducts?.currentPage ?? 0) + 1)),
      );

      return failureOrLoads.fold(
        (_) => error = 'Ошибка получения данных',
        (searchData) {
          searchProducts = searchData;

          // Получаем продукты из searchData
          final newProducts = searchData.products;

          // Объединяем старые продукты с новыми
          final updatedProducts = List<ProductEntity>.from(oldProducts)
            ..addAll(newProducts);

          // Используем copyWith для обновления списка продуктов
          searchProducts = searchProducts?.copyWith(products: updatedProducts);

          emit(
            state.copyWith(
                isLoading: false,
                isLoadingProducts: false,
                error: null,
                searchProducts: searchProducts),
          );
        },
      );
    }

    if (products != null) {
      emit(
        state.copyWith(
            isLoading: false, error: error, searchProducts: searchProducts),
      );
    }
  }

  @override
  Future<void> close() {
    // Очищаем ресурсы при закрытии блока
    productsController.removeListener(_scrollListener);
    productsController.dispose();
    return super.close();
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/search_products_entity.dart';
import 'package:inlek/features/domain/usecases/category/get_brands.dart';
import 'package:inlek/features/domain/usecases/category/get_countries.dart';
import 'package:inlek/features/domain/usecases/category/get_forms.dart';
import 'package:inlek/features/domain/usecases/products/search_products.dart';

part 'products_screen_event.dart';
part 'products_screen_state.dart';

class ProductsScreenBloc
    extends Bloc<ProductsScreenEvent, ProductsScreenState> {
  final SearchProductsUC searchProductsUC;
  final GetBrandsUC getBrandsUC;
  final GetFormsUC getFormsUC;
  final GetCountriesUC getCountriesUC;

  final ProductParam? productParam;
  final List<ProductEntity>? products;

  ScrollController productsController = ScrollController();

  TextEditingController minValueController = TextEditingController();
  TextEditingController maxValueController = TextEditingController();

  ProductsScreenBloc(
      {required this.searchProductsUC,
      this.productParam,
      this.products,
      required this.getBrandsUC,
      required this.getCountriesUC,
      required this.getFormsUC})
      : super(
          ProductsScreenState(productSortType: ProductSortType.popularity),
        ) {
    on<LoadProductsEvent>(_onLoadData);
    on<ChangeProductSortTypeEvent>(_onChangeProductSortTypeEvent);
    on<ChangePriceEvent>(_onChangePrice);
    on<SelectReleaseFormEvent>(_onSelectReleaseForm);
    on<SelectManufacturerEvent>(_onSelectManufacturer);
    on<SelectCountryEvent>(_onSelectCountry);
    on<ToggleWithoutPrescriptionEvent>(_onToggleWithoutPrescription);
    on<ToggleParticipatesInCampaignEvent>(_onToggleParticipatesInCampaign);
    on<ToggleDeliveryPossibleEvent>(_onToggleDeliveryPossible);
    on<ClearEvent>(_onClear);

    minValueController.text = '0';
    maxValueController.text = '50';

    // Добавляем слушатель для скролла
    if (products == null) productsController.addListener(_scrollListener);
  }

  void _scrollListener() {
    print("ScrollListener triggered"); // Печатаем, чтобы проверить срабатывание
    // Если скроллинг достиг нижней границы, загружаем следующую страницу
    if (productsController.position.pixels ==
        productsController.position.maxScrollExtent) {
      if (!state.isLoadingProducts && state.searchProducts != null &&
          state.searchProducts!.currentPage < state.searchProducts!.lastPage) {
        // Загружаем следующую страницу
        add(LoadProductsEvent(page: state.searchProducts!.currentPage + 1));
      }
    }
  }

  void _onChangeProductSortTypeEvent(
      ChangeProductSortTypeEvent event, Emitter<ProductsScreenState> emit) {
    emit(state.copyWith(productSortType: event.productSortType));

    // Повторно вызываем загрузку данных с новым типом сортировки
    add(LoadProductsEvent(page: 1));
  }

  void _onLoadData(
      LoadProductsEvent event, Emitter<ProductsScreenState> emit) async {
    // Загружаем фильтры только один раз
    if (!state.filtersLoaded && products == null) {
      List<String> brands = [];
      List<String> countries = [];
      List<String> forms = [];

      var data = await Future.wait([
        getBrandsUC(productParam!.categoryId!),
        getCountriesUC(productParam!.categoryId!),
        getFormsUC(productParam!.categoryId!),
      ]);

      for (var i = 0; i < data.length; i++) {
        data[i].fold(
          (_) {},
          (result) {
            switch (i) {
              case 0:
                brands = result;
                break;
              case 1:
                countries = result;
                break;
              case 2:
                forms = result;
                break;
            }
          },
        );
      }

      emit(state.copyWith(
          releaseForms: forms,
          manufacturers: brands,
          countries: countries,
          filtersLoaded: true));
    }

    // Загрузка продуктов
    SearchProductsEntity? searchProducts;
    String? error;

    if (products != null) {
      searchProducts = SearchProductsEntity(
        currentPage: 1,
        lastPage: 1,
        total: products!.length,
        products: products!,
      );
    }

    if (productParam != null) {
      int currentPage = event.page ?? (state.searchProducts?.currentPage ?? 1);
      List<ProductEntity> oldProducts = [];

      if (currentPage != 1) {
        emit(state.copyWith(isLoadingProducts: true));
        oldProducts = state.searchProducts?.products ?? [];
      } else {
        productsController.animateTo(0,
            duration: Duration(milliseconds: 300), curve: Curves.bounceIn);

        emit(state.copyWith(
            isLoadingProducts: true,
            searchProducts: state.searchProducts?.copyWith(products: [])));
      }

      final failureOrLoads = await searchProductsUC(
        productParam!.copyWith(
          sortBy: state.productSortType.apiValue,
          page: event.page ?? ((state.searchProducts?.currentPage ?? 0) + 1),
          priceFrom: state.minSelectedPrice.toInt(),
          priceTo: state.maxSelectedPrice.toInt(),
          releaseForm: state.selectedReleaseForms.toList(),
          brand: state.selectedManufacturers.toList(),
          country: state.selectedCountries.toList(),
          delivery: state.isDeliveryPossible == true ? 'true' : null,
          action: state.isParticipatesInCampaign ? 1 : null,
          recipe: state.isWithoutPrescription == true ? 'false' : null,
        ),
      );

      return failureOrLoads.fold(
        (_) => error = 'Ошибка получения данных',
        (searchData) {
          searchProducts = searchData;

          // Объединяем старые продукты с новыми
          final updatedProducts = List<ProductEntity>.from(oldProducts)
            ..addAll(searchData.products);

          searchProducts = searchProducts?.copyWith(products: updatedProducts);

          emit(state.copyWith(
            isLoading: false,
            isLoadingProducts: false,
            error: null,
            searchProducts: searchProducts,
          ));
        },
      );
    }

    if (products != null) {
      List<String> brands = state.manufacturers;
      List<String> countries = state.countries;
      List<String> forms = state.releaseForms;

      double minSelectedPrice = state.minSelectedPrice;
      double minAllowedPrice = state.minAllowedPrice;
      double maxSelectedPrice = state.maxSelectedPrice;
      double maxAllowedPrice = state.maxAllowedPrice;

      if (!state.filtersLoaded) {
        brands = products!.map((e) => e.brand ?? '-').toSet().toList();
        countries = products!.map((e) => e.country ?? '-').toSet().toList();
        forms = products!.map((e) => e.releaseForm ?? '-').toSet().toList();

        // Найдём минимальную и максимальную цену
        final prices =
            products!.map((e) => e.price).whereType<double>(); // Убираем null

        minSelectedPrice =
            prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;
        maxSelectedPrice =
            prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b) : 0.0;

        minSelectedPrice = minSelectedPrice.toInt().toDouble();
        minAllowedPrice = minSelectedPrice;
        maxSelectedPrice = maxSelectedPrice.ceil().toDouble();
        maxAllowedPrice = maxSelectedPrice;

        minValueController.text = minSelectedPrice.toStringAsFixed(0);
        maxValueController.text = maxSelectedPrice.toStringAsFixed(0);
      }

      // Фильтруем продукты по параметрам
      final filteredProducts = products!.where((product) {
        final matchesPrice = product.price != null &&
            product.price! >= minSelectedPrice &&
            product.price! <= maxSelectedPrice;
        final matchesBrand = state.selectedManufacturers.isEmpty ||
            state.selectedManufacturers.contains(product.brand);
        final matchesCountry = state.selectedCountries.isEmpty ||
            state.selectedCountries.contains(product.country);
        final matchesForm = state.selectedReleaseForms.isEmpty ||
            state.selectedReleaseForms.contains(product.releaseForm);
        /* final matchesDelivery =
            (state.isDeliveryPossible ? && product.delivery == 'Доставка');
        final matchesAction = state.isParticipatesInCampaign == false ||
            (state.isParticipatesInCampaign &&
                product.productSticker == 'action');
        final matchesRecipe =
            (state.isWithoutPrescription && product.recipe == 'Безрецептурный');*/

        return matchesPrice && matchesBrand && matchesCountry && matchesForm;
      }).toList();

      // 🔽 СОРТИРОВКА ПРОДУКТОВ
      switch (state.productSortType) {
        case ProductSortType.priceIncrease:
          filteredProducts
              .sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;

        case ProductSortType.priceDecrease:
          filteredProducts
              .sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;

        case ProductSortType.popularity:
          break;
      }

      searchProducts = SearchProductsEntity(
          currentPage: 1,
          lastPage: 1,
          total: filteredProducts.length,
          products: filteredProducts);

      emit(
        state.copyWith(
          isLoading: false,
          isLoadingProducts: false,
          minAllowedPrice: minAllowedPrice,
          minSelectedPrice: minSelectedPrice,
          maxAllowedPrice: maxAllowedPrice,
          maxSelectedPrice: maxSelectedPrice,
          error: error,
          searchProducts: searchProducts,
          releaseForms: forms,
          manufacturers: brands,
          countries: countries,
          filtersLoaded: true,
        ),
      );
    }
  }

  void _onChangePrice(
      ChangePriceEvent event, Emitter<ProductsScreenState> emit) {
    if (event.newPrice == null) return;

    // Ограничиваем цену в рамках допустимых значений
    final clampedPrice =
        event.newPrice!.clamp(state.minAllowedPrice, state.maxAllowedPrice);

    if (event.isMinPrice == true) {
      minValueController.text = clampedPrice.round().toString();
      emit(state.copyWith(minSelectedPrice: clampedPrice));
    } else {
      maxValueController.text = clampedPrice.round().toString();
      emit(state.copyWith(maxSelectedPrice: clampedPrice));
    }
  }

  void _onSelectReleaseForm(
      SelectReleaseFormEvent event, Emitter<ProductsScreenState> emit) {
    final updatedReleaseForms = Set<String>.from(state.selectedReleaseForms);
    if (event.isChecked == true) {
      updatedReleaseForms.add(event.releaseForm);
    } else {
      updatedReleaseForms.remove(event.releaseForm);
    }
    emit(state.copyWith(selectedReleaseForms: updatedReleaseForms));
  }

  void _onSelectManufacturer(
      SelectManufacturerEvent event, Emitter<ProductsScreenState> emit) {
    final updatedManufacturers = Set<String>.from(state.selectedManufacturers);
    if (event.isChecked == true) {
      updatedManufacturers.add(event.manufacturer);
    } else {
      updatedManufacturers.remove(event.manufacturer);
    }
    emit(state.copyWith(selectedManufacturers: updatedManufacturers));
  }

  void _onSelectCountry(
      SelectCountryEvent event, Emitter<ProductsScreenState> emit) {
    final updatedCountries = Set<String>.from(state.selectedCountries);
    if (event.isChecked == true) {
      updatedCountries.add(event.country);
    } else {
      updatedCountries.remove(event.country);
    }
    emit(state.copyWith(selectedCountries: updatedCountries));
  }

  void _onToggleWithoutPrescription(
      ToggleWithoutPrescriptionEvent event, Emitter<ProductsScreenState> emit) {
    emit(state.copyWith(isWithoutPrescription: event.isWithoutPrescription));
  }

  void _onToggleParticipatesInCampaign(ToggleParticipatesInCampaignEvent event,
      Emitter<ProductsScreenState> emit) {
    emit(state.copyWith(
        isParticipatesInCampaign: event.isParticipatesInCampaign));
  }

  void _onToggleDeliveryPossible(
      ToggleDeliveryPossibleEvent event, Emitter<ProductsScreenState> emit) {
    emit(state.copyWith(isDeliveryPossible: event.isDeliveryPossible));
  }

  void _onClear(ClearEvent event, Emitter<ProductsScreenState> emit) {
    minValueController.text = state.minAllowedPrice.toStringAsFixed(0);
    maxValueController.text = state.maxAllowedPrice.toStringAsFixed(0);
    emit(
      state.copyWith(
          selectedCountries: {},
          selectedManufacturers: {},
          selectedReleaseForms: {},
          isDeliveryPossible: false,
          isParticipatesInCampaign: false,
          isWithoutPrescription: false,
          minSelectedPrice: state.minAllowedPrice,
          maxSelectedPrice: state.maxAllowedPrice),
    );
    add(LoadProductsEvent(page: 1));
  }

  @override
  Future<void> close() {
    // Очищаем ресурсы при закрытии блока
    productsController.removeListener(_scrollListener);
    productsController.dispose();
    maxValueController.dispose();
    maxValueController.dispose();
    return super.close();
  }
}

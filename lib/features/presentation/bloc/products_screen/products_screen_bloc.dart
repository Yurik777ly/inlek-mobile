import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/usecases/products/search_products.dart';

part 'products_screen_event.dart';
part 'products_screen_state.dart';

class ProductsScreenBloc
    extends Bloc<ProductsScreenEvent, ProductsScreenState> {
  final SearchProductsUC searchProductsUC;

  final ProductParam? productParam;
  final List<ProductEntity>? products;

  ProductsScreenBloc(
      {required this.searchProductsUC, this.productParam, this.products})
      : super(
          ProductsScreenState(productSortType: ProductSortType.popularity),
        ) {
    on<LoadDataEvent>(_onLoadData);
    on<ChangeProductSortTypeEvent>(_onChangeProductSortTypeEvent);
  }

  void _onChangeProductSortTypeEvent(
      ChangeProductSortTypeEvent event, Emitter<ProductsScreenState> emit) {
    emit(state.copyWith(productSortType: event.productSortType));

    // Повторно вызываем загрузку данных с новым типом сортировки
    add(LoadDataEvent());
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<ProductsScreenState> emit) async {
    List<ProductEntity> products = this.products ?? [];
    String? error;

    if (productParam != null) {
      final failureOrLoads = await searchProductsUC(
        productParam!.copyWith(sortBy: state.productSortType!.apiValue),
      );

      return failureOrLoads.fold(
        (_) => error = 'Ошибка получения данных',
        (productList) {
          products = productList;
          emit(
            ProductsScreenState(
                isLoading: false,
                error: null,
                productSortType: ProductSortType.popularity,
                products: products),
          );
        },
      );
    }

    emit(
      ProductsScreenState(isLoading: false, error: error, products: products),
    );
  }
}

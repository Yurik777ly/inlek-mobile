import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/domain/entities/banner_entity.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/usecases/category/get_categories.dart';
import 'package:inlek/features/domain/usecases/content/get_actions.dart';
import 'package:inlek/features/domain/usecases/content/get_banners.dart';
import 'package:inlek/features/domain/usecases/products/get_daily_products.dart';

part 'main_screen_event.dart';
part 'main_screen_state.dart';

class MainScreenBloc extends Bloc<MainScreenEvent, MainScreenState> {
  final GetBannersUC getBannersUC;
  final GetCategoriesUC getCategoriesUC;
  final GetDailyProductsUC getDailyProductsUC;
  final GetActionsUC getActionsUC;

  MainScreenBloc({
    required this.getBannersUC,
    required this.getCategoriesUC,
    required this.getDailyProductsUC,
    required this.getActionsUC,
  }) : super(MainScreenState()) {
    on<LoadDataEvent>(_onLoadData);
  }

  void _onLoadData(LoadDataEvent event, Emitter<MainScreenState> emit) async {
    List<BannerEntity> banners = [];
    List<CategoryEntity> categories = [];
    List<ProductEntity> daily = [];
    List<ActionEntity> actions = [];

    var data = await Future.wait(
      [
        getCategoriesUC(),
        getDailyProductsUC(),
        getActionsUC(),
        getBannersUC(),
      ],
    );

    data.forEachIndexed(
      (index, element) {
        element.fold(
          (_) {},
          (result) => switch (index) {
            0 => categories = result as List<CategoryEntity>,
            1 => daily = (result as List<ProductEntity>)
                .where((product) => (product.price ?? 0) > 0)
                .toList(),
            2 => actions = result as List<ActionEntity>,
            3 => banners = result as List<BannerEntity>,
            _ => {},
          },
        );
      },
    );

    emit(
      MainScreenState(
          isLoading: false,
          banners: banners,
          categories: categories,
          daily: daily,
          actions: actions),
    );
  }
}

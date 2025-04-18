import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/products_screen/products_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/products_screen/products_grid_widget.dart';
import 'package:inlek/features/presentation/widgets/products_screen/sort_widget.dart';
import 'package:inlek/features/presentation/widgets/search_product_app_bar.dart';
import 'package:inlek/locator_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final title = args['title'] as String?;
    final productParam = args['productParam'] as ProductParam?;
    final products = args['products'] as List<ProductEntity>?;

    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        HomeScreenBloc homeBloc = context.read<HomeScreenBloc>();
        return BlocProvider(
          create: (context) => ProductsScreenBloc(
              searchProductsUC: sl(),
              getBrandsUC: sl(),
              getCountriesUC: sl(),
              getFormsUC: sl(),
              productParam: productParam,
              products: products)
            ..add(
              LoadProductsEvent(),
            ),
          child: BlocBuilder<ProductsScreenBloc, ProductsScreenState>(
            builder: (context, state) {
              ProductsScreenBloc bloc = context.read<ProductsScreenBloc>();
              return Scaffold(
                backgroundColor: UiConstants.backgroundColor,
                body: SafeArea(
                  child: Skeletonizer(
                    ignorePointers: false,
                    enabled: state.isLoading,
                    child: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            SearchProductAppBar(
                                screenContext: context,
                                showBack: true,
                                showFilters: true),
                            Expanded(
                              child: Padding(
                                padding: getMarginOrPadding(
                                    right: 20, left: 20, top: 16),
                                child: Builder(
                                  builder: (context) {
                                    return homeState is InternetUnavailable
                                        ? InternetNoInternetConnectionWidget()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title ?? '-',
                                                style: UiConstants.textStyle9
                                                    .copyWith(
                                                        color: UiConstants
                                                            .darkBlueColor),
                                              ),
                                              SizedBox(height: 8.h),
                                              Text(
                                                Utils.getProductCountText(state
                                                        .searchProducts
                                                        ?.total ??
                                                    0),
                                                style: UiConstants.textStyle3
                                                    .copyWith(
                                                  color: UiConstants
                                                      .darkBlue2Color
                                                      .withOpacity(.6),
                                                ),
                                              ),
                                              SizedBox(height: 16.h),
                                              SortWidget(
                                                onTap: () => BottomSheetManager
                                                    .showProductSortSheet(
                                                        UiConstants
                                                            .homeContext!,
                                                        context),
                                              ),
                                              SizedBox(height: 16.h),
                                              Expanded(
                                                child: ProductsGridWidget(
                                                    isLoading: state.isLoading,
                                                    isLoadingProducts:
                                                        state.isLoadingProducts,
                                                    products: state
                                                            .searchProducts
                                                            ?.products ??
                                                        [],
                                                    controller: bloc
                                                        .productsController),
                                              )
                                            ],
                                          );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

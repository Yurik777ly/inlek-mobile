import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/share_utils.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/products_screen/products_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/sale_screen/sale_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/main_screen/banner_item.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/products_screen/products_grid_widget.dart';
import 'package:inlek/features/presentation/widgets/products_screen/sort_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SaleScreen extends StatelessWidget {
  const SaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    int? id = args!['id'];

    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        return BlocProvider(
          create: (context) => SaleScreenBloc(
            screenContext: context,
            getOneActionUC: sl(),
          )..add(
              LoadActionEvent(id: id!),
            ),
          child: BlocBuilder<SaleScreenBloc, SaleScreenState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: UiConstants.backgroundColor,
                body: SafeArea(
                  child: Skeletonizer(
                    ignorePointers: false,
                    justifyMultiLineText: false,
                    textBoneBorderRadius:
                        TextBoneBorderRadius.fromHeightFactor(.5),
                    enabled: state.isLoading,
                    child: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            CustomAppBar(
                              showBack: true,
                              action: SvgPicture.asset(Paths.shareIconPath),
                              onTapAction: () => ShareUtils.shareUrl(
                                  ShareUrlType.sale, id.toString()),
                            ),
                            Expanded(
                              child: homeState is InternetUnavailable
                                  ? InternetNoInternetConnectionWidget()
                                  : ListView(
                                      shrinkWrap: true,
                                      padding: getMarginOrPadding(
                                          bottom: 94,
                                          top: 16,
                                          left: 20,
                                          right: 20),
                                      children: [
                                        BannerItem(
                                            height: 200.dp,
                                            url:
                                                '${dotenv.env['PUBLIC_URL']!}${state.action?.image}'),
                                        SizedBox(height: 10.dp),
                                        Text(
                                          state.action?.pageTitle ?? '',
                                          style: UiConstants.textStyle5
                                              .copyWith(
                                                  color: UiConstants
                                                      .darkBlueColor),
                                        ),
                                        SizedBox(height: 32.dp),
                                        BlocProvider(
                                          create: (context) =>
                                              ProductsScreenBloc(
                                                  searchProductsUC: sl(),
                                                  getBrandsUC: sl(),
                                                  getCountriesUC: sl(),
                                                  getFormsUC: sl(),
                                                  products: state
                                                      .action?.actionProducts)
                                                ..add(LoadProductsEvent()),
                                          child: BlocBuilder<ProductsScreenBloc,
                                              ProductsScreenState>(
                                            builder: (context, state) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Товары, участвующие в акции',
                                                    style: UiConstants
                                                        .textStyle5
                                                        .copyWith(
                                                            color: UiConstants
                                                                .darkBlueColor),
                                                  ),
                                                  SizedBox(height: 16.dp),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: SortWidget(
                                                          caption: 'Сортировка',
                                                          iconPath: Paths
                                                              .sortIconPath,
                                                          onTap: () =>
                                                              BottomSheetManager
                                                                  .showProductSortSheet(
                                                                      context),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.dp),
                                                      Expanded(
                                                        child: SortWidget(
                                                          caption: 'Фильтр',
                                                          iconPath: Paths
                                                              .filtersIconPath,
                                                          onTap: () =>
                                                              BottomSheetManager
                                                                  .showProductsFilterSheet(
                                                                      context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 16.dp),
                                                  ProductsGridWidget(
                                                      products: state
                                                              .searchProducts
                                                              ?.products ??
                                                          [],
                                                      isLoading:
                                                          state.isLoading,
                                                      isLoadingProducts:
                                                          state.isLoading,
                                                      scrollPhysics:
                                                          NeverScrollableScrollPhysics(),
                                                      controller: context
                                                          .read<
                                                              SaleScreenBloc>()
                                                          .controller),
                                                ],
                                              );
                                            },
                                          ),
                                        )
                                      ],
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

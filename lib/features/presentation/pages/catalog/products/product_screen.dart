import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/share_utils.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/product_screen/product_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/change_count_product_widget.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/custom_flutter_html.dart';
import 'package:inlek/features/presentation/widgets/dropdown_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/daily_products_list_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_banner_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_characteristic_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_receiving_methods_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_title_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    int? productId = args!['id'];

    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        final homeBloc = context.read<HomeScreenBloc>();
        return BlocProvider(
          create: (context) => ProductScreenBloc(
              productId: productId,
              getOneProductUC: sl(),
              getProductPharmaciesUC: sl())
            ..add(LoadDataEvent()),
          child: BlocBuilder<ProductScreenBloc, ProductScreenState>(
            builder: (context, productState) {
              final productBloc = context.read<ProductScreenBloc>();
              return Scaffold(
                appBar: AppBar(
                    toolbarHeight: 0,
                    backgroundColor: UiConstants.whiteColor,
                    surfaceTintColor: Colors.transparent),
                backgroundColor: UiConstants.backgroundColor,
                body: SafeArea(
                  child: Skeletonizer(
                    ignorePointers: false,
                    justifyMultiLineText: false,
                    textBoneBorderRadius:
                        TextBoneBorderRadius.fromHeightFactor(.5),
                    enabled: productState.isLoading,
                    child: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            CustomAppBar(
                              showBack: true,
                              action: SvgPicture.asset(Paths.shareIconPath),
                              onTapAction: () => ShareUtils.shareUrl(
                                  ShareUrlType.product, productId.toString()),
                            ),
                            Expanded(
                              child: homeState is InternetUnavailable
                                  ? InternetNoInternetConnectionWidget()
                                  : Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        ListView(
                                          shrinkWrap: true,
                                          padding: getMarginOrPadding(
                                              bottom: 120, top: 16),
                                          children: [
                                            ProductBannerWidget(
                                                pageController:
                                                    productBloc.pageController,
                                                product: productState.product),
                                            SizedBox(height: 16.dp),
                                            Padding(
                                              padding: getMarginOrPadding(
                                                  left: 20, right: 20),
                                              child: ProductTitleWidget(
                                                  product:
                                                      productState.product),
                                            ),
                                            SizedBox(height: 16.dp),
                                            Padding(
                                              padding: getMarginOrPadding(
                                                  left: 20, right: 20),
                                              child:
                                                  ProductReceivingMethodsWidget(
                                                pharmacies:
                                                    productState.pharmacies ??
                                                        [],
                                                product: productState.product ??
                                                    ProductEntity(),
                                              ),
                                            ),
                                            SizedBox(height: 16.dp),
                                            Padding(
                                              padding: getMarginOrPadding(
                                                  left: 20, right: 20),
                                              child: DropdownWidget(
                                                title: 'Характеристики',
                                                child:
                                                    ProductCharacteristicWidget(
                                                        product: productState
                                                            .product),
                                              ),
                                            ),
                                            if (productState
                                                    .product?.description !=
                                                null)
                                              Padding(
                                                padding: getMarginOrPadding(
                                                    left: 20,
                                                    right: 20,
                                                    top: 16),
                                                child: DropdownWidget(
                                                  title: 'Описание',
                                                  child: Skeleton.replace(
                                                    child: CustomFlutterHtml(
                                                        isLoading: productState
                                                            .isLoading,
                                                        content: productState
                                                                .product
                                                                ?.description ??
                                                            '-'),
                                                  ),
                                                ),
                                              ),
                                            if ((productState.product
                                                        ?.similarProducts ??
                                                    [])
                                                .isNotEmpty)
                                              Padding(
                                                padding:
                                                    getMarginOrPadding(top: 32),
                                                child: BlockWidget(
                                                  contentPadding:
                                                      getMarginOrPadding(
                                                          left: 20, right: 20),
                                                  title: 'Аналоги',
                                                  child: ProductsListWidget(
                                                      products: productState
                                                              .product
                                                              ?.similarProducts ??
                                                          []),
                                                ),
                                              ),
                                            SizedBox(height: 32.dp),
                                          ],
                                        ),
                                        Positioned(
                                          left: 20.dp,
                                          right: 20.dp,
                                          bottom: 94,
                                          child: (productState.pharmacies ?? [])
                                                  .isEmpty
                                              ? AppButtonWidget(
                                                  text:
                                                      'Сообщить о поступлении',
                                                  onTap: () => BottomSheetManager
                                                      .showProductReceiptNotificationSheet(
                                                          homeBloc
                                                              .state.context!),
                                                )
                                              : BlocBuilder<CartScreenBloc,
                                                  CartScreenState>(
                                                  builder: (context, state) {
                                                    return ChangeCountProductWidget(
                                                        product: productState
                                                            .product!);
                                                  },
                                                ),
                                        ),
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

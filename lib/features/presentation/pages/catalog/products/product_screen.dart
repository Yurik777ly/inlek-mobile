import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
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
import 'package:inlek/features/presentation/widgets/product_screen/instruction_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/prescription_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_banner_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_characteristic_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_receiving_methods_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_title_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class _ProductAnalogResult {
  final List<ProductEntity> products;
  final String title;

  const _ProductAnalogResult({
    required this.products,
    required this.title,
  });
}

_ProductAnalogResult? _getProductsToDisplay(ProductEntity product) {
  // Определяем, является ли товар ЛП (лекарственным препаратом)
  // ЛП - это товары с категориями ID 3 или 344
  final isLP = product.categoriesJson?.any((category) =>
          category.categoryId == 3 || category.categoryId == 344) ??
      false;

  if (isLP) {
    // Для ЛП: аналоги по МНН+форме (как на сайте), затем похожие товары
    if ((product.analogProducts ?? []).isNotEmpty) {
      return _ProductAnalogResult(
        products: product.analogProducts!,
        title: 'Аналоги',
      );
    } else if ((product.relatedProducts ?? []).isNotEmpty) {
      return _ProductAnalogResult(
        products: product.relatedProducts!,
        title: 'Аналоги',
      );
    } else if ((product.similarProducts ?? []).isNotEmpty) {
      return _ProductAnalogResult(
        products: product.similarProducts!,
        title: 'Похожие товары',
      );
    }
  } else {
    // Для не-ЛП: сначала похожие товары, потом аналоги, потом товары бренда
    if ((product.similarProducts ?? []).isNotEmpty) {
      return _ProductAnalogResult(
        products: product.similarProducts!,
        title: 'Похожие товары',
      );
    } else if ((product.analogProducts ?? []).isNotEmpty) {
      return _ProductAnalogResult(
        products: product.analogProducts!,
        title: 'Аналоги',
      );
    } else if ((product.relatedProducts ?? []).isNotEmpty) {
      return _ProductAnalogResult(
        products: product.relatedProducts!,
        title: 'Аналоги',
      );
    } else if ((product.brandProducts ?? []).isNotEmpty) {
      return _ProductAnalogResult(
        products: product.brandProducts!,
        title: 'Товары бренда',
      );
    }
  }

  return null;
}

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
            getProductPharmaciesUC: sl(),
            sharedPreferences: sl(),
          )..add(LoadDataEvent()),
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
                    enabled: productState.isLoadingProducts,
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
                                  : (productState.error != null
                                      ? Center(
                                          child: Padding(
                                            padding: getMarginOrPadding(
                                                left: 20, right: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  Paths.infoIconPath,
                                                  width: 48,
                                                  height: 48,
                                                  color: UiConstants.redColor,
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  productState.error ??
                                                      'Ошибка',
                                                  style: UiConstants.textStyle5
                                                      .copyWith(
                                                    color: UiConstants
                                                        .darkBlueColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            ListView(
                                              shrinkWrap: true,
                                              padding: getMarginOrPadding(
                                                  bottom: 120, top: 16),
                                              children: [
                                                ProductBannerWidget(
                                                    pageController: productBloc
                                                        .pageController,
                                                    product:
                                                        productState.product),
                                                SizedBox(height: 16),
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      left: 20, right: 20),
                                                  child: ProductTitleWidget(
                                                      product:
                                                          productState.product),
                                                ),
                                                if (productState.product
                                                            ?.isAlcohol ==
                                                        true ||
                                                    productState.product
                                                            ?.isRecipe ==
                                                        true)
                                                  Padding(
                                                    padding: getMarginOrPadding(
                                                        top: 16,
                                                        left: 20,
                                                        right: 20),
                                                    child: PrescriptionWidget(),
                                                  ),
                                                if (productState
                                                        .product?.instruction !=
                                                    null)
                                                  Padding(
                                                    padding: getMarginOrPadding(
                                                        top: 16,
                                                        left: 20,
                                                        right: 20),
                                                    child: InstructionWidget(
                                                        instruction: productState
                                                                .product
                                                                ?.instruction ??
                                                            ''),
                                                  ),
                                                SizedBox(height: 16),
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      left: 20, right: 20),
                                                  child:
                                                      ProductReceivingMethodsWidget(
                                                    isLoadingPharmacies:
                                                        productState
                                                            .isLoadingPharmacies,
                                                    pharmacies: productState
                                                            .pharmacies ??
                                                        [],
                                                    product:
                                                        productState.product ??
                                                            ProductEntity(),
                                                  ),
                                                ),
                                                SizedBox(height: 16),
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      left: 20, right: 20),
                                                  child: DropdownWidget(
                                                    title: 'Характеристики',
                                                    child:
                                                        ProductCharacteristicWidget(
                                                            product:
                                                                productState
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
                                                                .isLoadingProducts,
                                                            content: productState
                                                                    .product
                                                                    ?.description ??
                                                                '-'),
                                                      ),
                                                    ),
                                                  ),
                                                Builder(
                                                  builder: (context) {
                                                    final product =
                                                        productState.product;
                                                    if (product == null)
                                                      return SizedBox.shrink();

                                                    final analogResult =
                                                        _getProductsToDisplay(
                                                            product);
                                                    if (analogResult == null)
                                                      return SizedBox.shrink();

                                                    return Padding(
                                                      padding:
                                                          getMarginOrPadding(
                                                              top: 32),
                                                      child: BlockWidget(
                                                        contentPadding:
                                                            getMarginOrPadding(
                                                                left: 20,
                                                                right: 20),
                                                        title:
                                                            analogResult.title,
                                                        child: ProductsListWidget(
                                                            products:
                                                                analogResult
                                                                    .products),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                SizedBox(height: 32),
                                              ],
                                            ),
                                            Positioned(
                                              left: 20,
                                              right: 20,
                                              bottom: 94,
                                              child: productState.product
                                                              ?.availability ==
                                                          'absent' ||
                                                      productState
                                                          .isLoadingProducts
                                                  ? AppButtonWidget(
                                                      text:
                                                          'Сообщить о поступлении',
                                                      onTap: () async {
                                                        bool?
                                                            isContinueShopping =
                                                            await BottomSheetManager
                                                                .showProductReceiptNotificationSheet();
                                                        if (isContinueShopping ==
                                                                true &&
                                                            context.mounted) {
                                                          homeBloc.add(
                                                              ChangePageEvent(1,
                                                                  forcePopToRoot:
                                                                      true));
                                                        }
                                                      },
                                                    )
                                                  : BlocBuilder<CartScreenBloc,
                                                      CartScreenState>(
                                                      builder:
                                                          (context, state) {
                                                        return ChangeCountProductWidget(
                                                            product:
                                                                productState
                                                                    .product!,
                                                            screenContext:
                                                                context);
                                                      },
                                                    ),
                                            ),
                                          ],
                                        )),
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

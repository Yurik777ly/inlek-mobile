import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/cart_pharmacy_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/empty_cart_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/products_list_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/selector/selector.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/summary_block/card_summary_block.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/unavailable_for_delivery_widget.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/custom_checkbox.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        return BlocBuilder<CartScreenBloc, CartScreenState>(
          builder: (context, cartState) {
            CartScreenBloc cartBloc = context.read<CartScreenBloc>();

            List<ProductEntity> inStockProducts = [];
            List<ProductEntity> pickUpAndInStockProducts = [];
            List<ProductEntity> noInStockProducts = [];

            for (ProductEntity product in cartState.cartData?.products ?? []) {
              bool isLoadingProduct = product.price == null;
              bool isInStock =
                  product.availability == 'full' || isLoadingProduct;

              // Определяем, в каком списке должен быть продукт
              if (isInStock) {
                bool isRestrictedProduct =
                    product.isRecipe || product.isAlcohol;
                // Добавляем в список для самовывоза, если тип получения — самовывоз и товар в наличии
                if (isRestrictedProduct &&
                    cartState.cartType == TypeReceiving.delivery) {
                  pickUpAndInStockProducts.add(product);
                } else {
                  inStockProducts.add(product);
                }
              } else {
                noInStockProducts.add(product);
              }
            }

            bool isDeliverySelected =
                cartState.cartType == TypeReceiving.delivery &&
                    pickUpAndInStockProducts.any(
                      (e) => cartState.selectedProductIds.contains(e.productId),
                    );

            bool isPickupWithoutSelectedPharmacy =
                cartState.cartType == TypeReceiving.pickup &&
                    cartState.selectedPharmacyId == null;

            return Scaffold(
              backgroundColor: UiConstants.backgroundColor,
              body: SafeArea(
                child: Skeletonizer(
                  ignorePointers: false,
                  enabled: cartState.isLoading,
                  child: Builder(
                    builder: (context) {
                      return Column(
                        children: [
                          CustomAppBar(
                              title: 'Корзина',
                              action: (cartState.cartData?.products ?? [])
                                      .isNotEmpty
                                  ? GestureDetector(
                                      onTap: () =>
                                          BottomSheetManager.showClearCartSheet(
                                              context),
                                      child: Text(
                                        'Очистить корзину',
                                        style: UiConstants.textStyle3.copyWith(
                                          color: UiConstants.darkBlue2Color
                                              .withOpacity(.6),
                                        ),
                                      ),
                                    )
                                  : null),
                          homeState is InternetUnavailable
                              ? InternetNoInternetConnectionWidget()
                              : (cartState.cartData?.products ?? []).isNotEmpty
                                  ? Expanded(
                                      child: Builder(
                                        builder: (context) {
                                          return ListView(
                                            controller: cartBloc.controller,
                                            shrinkWrap: true,
                                            padding: getMarginOrPadding(
                                                bottom: 94,
                                                right: 20,
                                                left: 20,
                                                top: 16),
                                            children: [
                                              Padding(
                                                padding: getMarginOrPadding(
                                                    bottom: 12),
                                                child: Text(
                                                  'Выберите способ получения',
                                                  style: UiConstants.textStyle5
                                                      .copyWith(
                                                          color: UiConstants
                                                              .darkBlueColor),
                                                ),
                                              ),
                                              // селектор доставка/самовывоз
                                              Align(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                child: Selector(
                                                  titlesList: const [
                                                    'Доставка',
                                                    'Самовывоз'
                                                  ],
                                                  unavailableList: [
                                                    if (!cartState
                                                        .isAvailableDelivery)
                                                      'Доставка'
                                                  ],
                                                  selectedIndex: [
                                                    TypeReceiving.delivery,
                                                    TypeReceiving.pickup
                                                  ].indexOf(cartState.cartType),
                                                  onTap: (int index) {
                                                    cartBloc.add(
                                                      ChangeCartTypeEvent(
                                                        [
                                                          TypeReceiving
                                                              .delivery,
                                                          TypeReceiving.pickup
                                                        ][index],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 16.dp),
                                              // виджет выбрать всё
                                              //if (cartState
                                              //    .cartData!.products!
                                              //    .any((e) => e.inStock))
                                              Padding(
                                                padding: getMarginOrPadding(
                                                    bottom: 16),
                                                child: CustomCheckbox(
                                                  title: Text(
                                                    'Выбрать всё',
                                                    style: UiConstants
                                                        .textStyle8
                                                        .copyWith(
                                                            color: UiConstants
                                                                .blackColor),
                                                  ),
                                                  isChecked: cartState
                                                      .isAllProductsChecked,
                                                  onChanged: (_) => cartBloc.add(
                                                      PickAllProductsEvent()),
                                                ),
                                              ),

                                              // виджет аптеки
                                              if (cartState.cartType ==
                                                  TypeReceiving.pickup)
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      bottom: 16),
                                                  child: BlockWidget(
                                                      title: 'Аптека',
                                                      clickableText:
                                                          cartState.selectedPharmacyId !=
                                                                  null
                                                              ? 'Изменить'
                                                              : 'Выбрать аптеку',
                                                      clickableTextColor:
                                                          UiConstants
                                                              .pink2Color,
                                                      onTap: () =>
                                                          BottomSheetManager
                                                              .showSelectPharmacySheet(
                                                                  context),
                                                      child: cartState.cartData
                                                                  ?.pharmacy !=
                                                              null
                                                          ? CartPharmacyWidget(
                                                              pharmacy: cartState
                                                                  .cartData!
                                                                  .pharmacy!)
                                                          : null),
                                                ),
                                              // список с товарами, доступными для доставки
                                              if (inStockProducts.isNotEmpty)
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      bottom: 32),
                                                  child: ProductsListWidget(
                                                      products: inStockProducts,
                                                      productsListScreenType:
                                                          ProductsListScreenType
                                                              .cart),
                                                ),
                                              // надпись самовывоза
                                              if (pickUpAndInStockProducts
                                                      .isNotEmpty &&
                                                  cartState.cartType ==
                                                      TypeReceiving.delivery)
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      bottom: 32),
                                                  child:
                                                      UnavailableForDeliveryWidget(),
                                                ),
                                              // список с товарами, доступными только для самовывоза
                                              if (pickUpAndInStockProducts
                                                      .isNotEmpty &&
                                                  cartState.cartType ==
                                                      TypeReceiving.delivery)
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      bottom: 32),
                                                  child: ProductsListWidget(
                                                      title: 'Только самовывоз',
                                                      products:
                                                          pickUpAndInStockProducts,
                                                      productsListScreenType:
                                                          ProductsListScreenType
                                                              .cart),
                                                ),
                                              // список с законченными товарами
                                              if (noInStockProducts.isNotEmpty)
                                                Padding(
                                                  padding: getMarginOrPadding(
                                                      bottom: 32),
                                                  child: ProductsListWidget(
                                                      title:
                                                          'Товары закончились',
                                                      products:
                                                          noInStockProducts,
                                                      productsListScreenType:
                                                          ProductsListScreenType
                                                              .cart),
                                                ),
                                              // подсчёт стоимости

                                              Padding(
                                                padding: getMarginOrPadding(
                                                    bottom: 32),
                                                child: CardSummaryBlock(
                                                  canUsePromoCodes: true,
                                                  products: cartState
                                                          .cartData?.products
                                                          .where((product) => cartState
                                                              .selectedProductIds
                                                              .contains(product
                                                                  .productId))
                                                          .toList() ??
                                                      [],
                                                ),
                                              ),
                                              // кнопка оформления

                                              AppButtonWidget(
                                                text: 'Перейти к оформлению',
                                                textWidget:
                                                    cartState.isOrderCompleting
                                                        ? Center(
                                                            child: SizedBox(
                                                              width: 15,
                                                              height: 15,
                                                              child: CircularProgressIndicator(
                                                                  color: UiConstants
                                                                      .pink2Color),
                                                            ),
                                                          )
                                                        : null,
                                                onTap:
                                                    cartState.isOrderCompleting
                                                        ? () {}
                                                        : () async {
                                                            if (cartState
                                                                .selectedProductIds
                                                                .isEmpty) {
                                                              ScaffoldMessenger
                                                                  .of(context)
                                                                ..hideCurrentSnackBar()
                                                                ..showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Пожалуйста, выберите хотя бы один товар'),
                                                                  ),
                                                                );
                                                            } else if (isPickupWithoutSelectedPharmacy) {
                                                              ScaffoldMessenger
                                                                  .of(context)
                                                                ..hideCurrentSnackBar()
                                                                ..showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Пожалуйста, выберите аптеку для самовывоза'),
                                                                  ),
                                                                );
                                                            } else if (isDeliverySelected) {
                                                              bool?
                                                                  isChangeToPickupType =
                                                                  await BottomSheetManager.showNotAllProductsAvailableDeliverySheet(
                                                                      context,
                                                                      UiConstants
                                                                          .homeContext!);

                                                              if (isChangeToPickupType ==
                                                                  true) {
                                                                cartBloc.add(
                                                                  ChangeCartTypeEvent(
                                                                      TypeReceiving
                                                                          .pickup),
                                                                );
                                                                cartBloc.add(
                                                                  ScrollUpListEvent(),
                                                                );
                                                              }
                                                            } else {
                                                              BottomSheetManager
                                                                  .showDeliverySheet(
                                                                      context);
                                                            }
                                                          },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : Expanded(
                                      child: Padding(
                                        padding: getMarginOrPadding(
                                            left: 20, right: 20, top: 16),
                                        child: Column(
                                          children: [
                                            // селектор доставка/самовывоз
                                            Align(
                                              alignment:
                                                  AlignmentDirectional.center,
                                              child: Selector(
                                                titlesList: const [
                                                  'Доставка',
                                                  'Самовывоз'
                                                ],
                                                unavailableList: [
                                                  if (!cartState
                                                      .isAvailableDelivery)
                                                    'Доставка'
                                                ],
                                                selectedIndex: [
                                                  TypeReceiving.delivery,
                                                  TypeReceiving.pickup
                                                ].indexOf(cartState.cartType),
                                                onTap: (int index) {
                                                  cartBloc.add(
                                                    ChangeCartTypeEvent(
                                                      [
                                                        TypeReceiving.delivery,
                                                        TypeReceiving.pickup
                                                      ][index],
                                                    ),
                                                  );
                                                  // Sync with bloc when user changes selection in empty cart
                                                  cartBloc.add(
                                                    ChangeCartTypeEvent(
                                                      [
                                                        TypeReceiving.delivery,
                                                        TypeReceiving.pickup
                                                      ][index],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 16.dp),
                                            Expanded(
                                              child: EmptyCartWidget(),
                                            ),
                                          ],
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
        );
      },
    );
  }
}

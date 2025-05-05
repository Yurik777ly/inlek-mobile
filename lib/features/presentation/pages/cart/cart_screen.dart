import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
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
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/cubit/selector_cubit.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/selector/selector.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/summary_block/card_summary_block.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/unavailable_for_delivery_widget.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/custom_checkbox.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
              if (product.delivery == TypeReceiving.delivery ||
                  isLoadingProduct ||
                  cartState.cartType == TypeReceiving.pickup) {
                inStockProducts.add(product);
              } else {
                pickUpAndInStockProducts.add(product);
              }
            }

            bool isDeliverySelected =
                cartState.cartType == TypeReceiving.delivery &&
                    pickUpAndInStockProducts.any(
                      (e) => cartState.selectedProductIds.contains(e.productId),
                    );

            bool isPickupWithoutSelectedPharmacy =
                cartState.cartType == TypeReceiving.pickup &&
                    cartState.selectedPharmacy == null;

            bool isShowCreateOrderButton =
                !(isDeliverySelected || isPickupWithoutSelectedPharmacy);

            return BlocProvider(
              create: (context) => SelectorCubit(
                index: [TypeReceiving.delivery, TypeReceiving.pickup]
                    .indexOf(cartState.cartType),
              ),
              child: BlocBuilder<SelectorCubit, SelectorState>(
                builder: (context, state) {
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
                                            onTap: () => BottomSheetManager
                                                .showClearCartSheet(context),
                                            child: Text(
                                              'Очистить корзину',
                                              style: UiConstants.textStyle3
                                                  .copyWith(
                                                color: UiConstants
                                                    .darkBlue2Color
                                                    .withOpacity(.6),
                                              ),
                                            ),
                                          )
                                        : null),
                                homeState is InternetUnavailable
                                    ? InternetNoInternetConnectionWidget()
                                    : (cartState.cartData?.products ?? [])
                                            .isNotEmpty
                                        ? Expanded(
                                            child: Builder(
                                              builder: (context) {
                                                return ListView(
                                                  controller:
                                                      cartBloc.controller,
                                                  shrinkWrap: true,
                                                  padding: getMarginOrPadding(
                                                      bottom: 94,
                                                      right: 20,
                                                      left: 20,
                                                      top: 16),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          getMarginOrPadding(
                                                              bottom: 12),
                                                      child: Text(
                                                        'Выберите способ получения',
                                                        style: UiConstants
                                                            .textStyle5
                                                            .copyWith(
                                                                color: UiConstants
                                                                    .darkBlueColor),
                                                      ),
                                                    ),
                                                    // селектор доставка/самовывоз
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .center,
                                                      child: Selector(
                                                        titlesList: const [
                                                          'Доставка',
                                                          'Самовывоз'
                                                        ],
                                                        onTap: (int index) =>
                                                            cartBloc.add(
                                                          ChangeCartTypeEvent(
                                                            [
                                                              TypeReceiving
                                                                  .delivery,
                                                              TypeReceiving
                                                                  .pickup
                                                            ][index],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 16.h),
                                                    // виджет выбрать всё
                                                    //if (cartState
                                                    //    .cartData!.products!
                                                    //    .any((e) => e.inStock))
                                                    Padding(
                                                      padding:
                                                          getMarginOrPadding(
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
                                                        onChanged: (_) =>
                                                            cartBloc.add(
                                                                PickAllProductsEvent()),
                                                      ),
                                                    ),

                                                    // виджет аптеки
                                                    if (cartState.cartType ==
                                                        TypeReceiving.pickup)
                                                      Padding(
                                                        padding:
                                                            getMarginOrPadding(
                                                                bottom: 16),
                                                        child: BlockWidget(
                                                            title: 'Аптека',
                                                            clickableText: cartState
                                                                        .selectedPharmacy !=
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
                                                            child: cartState
                                                                        .selectedPharmacy !=
                                                                    null
                                                                ? CartPharmacyWidget(
                                                                    pharmacy:
                                                                        cartState
                                                                            .selectedPharmacy!)
                                                                : null),
                                                      ),
                                                    // список с товарами, доступными для доставки
                                                    if (inStockProducts
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            getMarginOrPadding(
                                                                bottom: 32),
                                                        child: ProductsListWidget(
                                                            products:
                                                                inStockProducts,
                                                            productsListScreenType:
                                                                ProductsListScreenType
                                                                    .cart),
                                                      ),
                                                    // надпись самовывоза
                                                    if (pickUpAndInStockProducts
                                                            .isNotEmpty &&
                                                        cartState.cartType ==
                                                            TypeReceiving
                                                                .delivery)
                                                      Padding(
                                                        padding:
                                                            getMarginOrPadding(
                                                                bottom: 32),
                                                        child:
                                                            UnavailableForDeliveryWidget(),
                                                      ),
                                                    // список с товарами, доступными только для самовывоза
                                                    if (pickUpAndInStockProducts
                                                            .isNotEmpty &&
                                                        cartState.cartType ==
                                                            TypeReceiving
                                                                .delivery)
                                                      Padding(
                                                        padding:
                                                            getMarginOrPadding(
                                                                bottom: 32),
                                                        child: ProductsListWidget(
                                                            title:
                                                                'Только самовывоз',
                                                            products:
                                                                pickUpAndInStockProducts,
                                                            productsListScreenType:
                                                                ProductsListScreenType
                                                                    .cart),
                                                      ),
                                                    // список с законченными товарами
                                                    if (noInStockProducts
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            getMarginOrPadding(
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
                                                      padding:
                                                          getMarginOrPadding(
                                                              bottom: 32),
                                                      child: CardSummaryBlock(
                                                          canUsePromoCodes:
                                                              true),
                                                    ),
                                                    // кнопка оформления

                                                    AppButtonWidget(
                                                      text:
                                                          'Перейти к оформлению',
                                                      onTap: () {
                                                        if (cartState
                                                            .selectedProductIds
                                                            .isEmpty) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Пожалуйста, выберите хотя бы один товар'),
                                                            ),
                                                          );
                                                        } else if (isPickupWithoutSelectedPharmacy) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Пожалуйста, выберите аптеку для самовывоза'),
                                                            ),
                                                          );
                                                        } else if (isDeliverySelected) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Для доставки выберите аптеку с нужным товаром'),
                                                            ),
                                                          );
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
                                                        AlignmentDirectional
                                                            .center,
                                                    child: Selector(
                                                      titlesList: const [
                                                        'Доставка',
                                                        'Самовывоз'
                                                      ],
                                                      onTap: (int index) =>
                                                          cartBloc.add(
                                                        ChangeCartTypeEvent(
                                                          TypeReceiving
                                                              .values[index],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 16.h),
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
              ),
            );
          },
        );
      },
    );
  }
}

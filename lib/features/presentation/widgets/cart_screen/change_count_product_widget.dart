import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';

class ChangeCountProductWidget extends StatelessWidget {
  const ChangeCountProductWidget({
    super.key,
    required this.product,
    this.cartOrProductType = CartOrProductType.product,
    this.screenContext,
    this.cartBloc,
  });

  final ProductEntity product;
  final CartOrProductType cartOrProductType;
  final BuildContext? screenContext;
  final CartScreenBloc? cartBloc;

  @override
  Widget build(BuildContext context) {
    // Use provided bloc or try to get from context
    CartScreenBloc? effectiveCartBloc = cartBloc;
    if (effectiveCartBloc == null) {
      try {
        effectiveCartBloc = (screenContext ?? context).read<CartScreenBloc>();
      } catch (e) {
        // If no bloc is available, return empty container
        return Container();
      }
    }

    final cartProduct = (effectiveCartBloc.state.cartData?.products ?? [])
        .firstWhereOrNull((e) => e.productId == product.productId);
    final isCart = cartOrProductType == CartOrProductType.cart;
    final isProduct = cartOrProductType == CartOrProductType.product;
    int count = cartProduct?.quantity ?? 0;
    if (count == 0 && (cartProduct?.requestedQuantity ?? 0) > 0) {
      count = cartProduct!.requestedQuantity!;
    }
    double? price = cartProduct?.availability == 'absent'
        ? product.price
        : cartProduct?.prices?.price ?? product.price;
    final isAddDisabled = (cartProduct?.quantity ?? 0) >=
        (cartProduct?.stockCount ?? product.stockCount ?? double.infinity);
    final isLoading = (cartProduct ?? product).isLoading;

    if (isProduct && count == 0 && cartProduct?.availability != 'absent') {
      return _AddToCartButton(
          product: product,
          cartBloc: effectiveCartBloc,
          isLoading: isLoading,
          screenContext: screenContext ?? context);
    } else if (isCart) {
      return CartQuantityChanger(
        count: count,
        price: price,
        isAddDisabled: isAddDisabled,
        product: product,
        cartBloc: effectiveCartBloc,
        screenContext: screenContext,
      );
    } else {
      return ProductQuantityChanger(
        count: count,
        price: price,
        isAddDisabled: isAddDisabled,
        product: product,
        cartBloc: effectiveCartBloc,
        screenContext: screenContext,
      );
    }
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.product,
    required this.cartBloc,
    required this.isLoading,
    required this.screenContext,
  });

  final ProductEntity product;
  final CartScreenBloc cartBloc;
  final bool isLoading;
  final BuildContext screenContext;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (product.availableSomewhere == 0) {
          await BottomSheetManager.showProductReceiptNotificationSheet();
        } else {
          cartBloc.add(AddCartEvent(
            context: screenContext,
            productId: product.productId,
            onSuccess: () {
              final messengerContext =
                  Utils.resolveActiveContext(screenContext);
              if (messengerContext == null) return;
              ScaffoldMessenger.of(messengerContext)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Товар добавлен в корзину')),
                );
            },
          ));
        }
      },
      child: Container(
        height: 44,
        padding: getMarginOrPadding(left: 20, right: 20, top: 5.5, bottom: 5.5),
        decoration: BoxDecoration(
          color: UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: UiConstants.pink2Color)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (product.availableSomewhere == 0)
                      SvgPicture.asset(Paths.bellIconPath,
                          color: UiConstants.whiteColor)
                    else
                      Text(
                        'В корзину',
                        style: UiConstants.textStyle2.copyWith(
                          color: UiConstants.whiteColor,
                        ),
                      ),
                    if (product.isRecipe == true || product.isAlcohol == true)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Только самовывоз',
                          style: UiConstants.textStyle8.copyWith(
                            color: UiConstants.whiteColor,
                            height: 1,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class CartQuantityChanger extends StatelessWidget {
  const CartQuantityChanger({
    required this.count,
    required this.price,
    required this.isAddDisabled,
    required this.product,
    required this.cartBloc,
    this.screenContext,
    super.key,
  });

  final int count;
  final double? price;
  final bool isAddDisabled;
  final ProductEntity product;
  final CartScreenBloc cartBloc;
  final BuildContext? screenContext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 88,
          height: 44,
          padding: getMarginOrPadding(all: 8),
          decoration: BoxDecoration(
            color: UiConstants.white2Color,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              // Минус
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    Paths.minusIconPath,
                    width: 16,
                    height: 16,
                    color: UiConstants.darkBlueColor,
                  ),
                ),
              ),
              // Количество
              Expanded(
                flex: 2,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$count',
                      style: UiConstants.textStyle8.copyWith(
                        color: UiConstants.darkBlueColor,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // Плюс
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    Paths.plusIconPath,
                    width: 16,
                    height: 16,
                    color: isAddDisabled
                        ? UiConstants.blackColor.withOpacity(.4)
                        : UiConstants.darkBlueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) {
                    print(
                        '➖ CartQuantityChanger: minus button onTapDown for product ${product.productId}');
                  },
                  onTap: () {
                    print(
                        '➖ CartQuantityChanger: minus button tapped for product ${product.productId}');
                    cartBloc.add(
                      DeleteCartEvent(
                        context: screenContext ?? context,
                        productId: product.productId,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) {
                    print(
                        '➕ CartQuantityChanger: plus button onTapDown for product ${product.productId}');
                  },
                  onTap: isAddDisabled
                      ? () {
                          print(
                              '➕ CartQuantityChanger: plus button tapped (disabled) for product ${product.productId}');
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                              content: Text('Больше нет в наличии'),
                            ));
                        }
                      : () {
                          print(
                              '➕ CartQuantityChanger: plus button tapped for product ${product.productId}');
                          cartBloc.add(
                            AddCartEvent(
                              context: screenContext ?? context,
                              productId: product.productId,
                            ),
                          );
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ProductQuantityChanger extends StatelessWidget {
  const ProductQuantityChanger({
    required this.count,
    required this.price,
    required this.isAddDisabled,
    required this.product,
    required this.cartBloc,
    this.screenContext,
    super.key,
  });

  final int count;
  final double? price;
  final bool isAddDisabled;
  final ProductEntity product;
  final CartScreenBloc cartBloc;
  final BuildContext? screenContext;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => print('Шкибиди'),
      child: Container(
        height: 44,
        padding: getMarginOrPadding(left: 20, right: 20, top: 5.5, bottom: 5.5),
        decoration: BoxDecoration(
          color: UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            // Минус
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      Paths.minusIconPath,
                      width: 24,
                      height: 24,
                      color: UiConstants.whiteColor,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTapDown: (_) {
                          print(
                              '➖ ProductQuantityChanger: minus button onTapDown for product ${product.productId}');
                        },
                        onTap: () {
                          print(
                              '➖ ProductQuantityChanger: minus button tapped for product ${product.productId}');
                          cartBloc.add(
                            DeleteCartEvent(
                              context: screenContext ?? context,
                              productId: product.productId,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Количество и цена
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$count',
                      style: UiConstants.textStyle3.copyWith(
                        color: UiConstants.whiteColor,
                        height: 1,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      Utils.formatPrice((price ?? 0.0) * count),
                      style: UiConstants.textStyle8.copyWith(
                        color: UiConstants.whiteColor.withOpacity(.6),
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Плюс
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      Paths.plusIconPath,
                      width: 24,
                      height: 24,
                      color: isAddDisabled
                          ? UiConstants.whiteColor.withOpacity(.4)
                          : UiConstants.whiteColor,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTapDown: (_) {
                          print(
                              '➕ ProductQuantityChanger: plus button onTapDown for product ${product.productId}');
                        },
                        onTap: isAddDisabled
                            ? () {
                                print(
                                    '➕ ProductQuantityChanger: plus button tapped (disabled) for product ${product.productId}');
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(const SnackBar(
                                    content: Text('Больше нет в наличии'),
                                  ));
                              }
                            : () {
                                print(
                                    '➕ ProductQuantityChanger: plus button tapped for product ${product.productId}');
                                cartBloc.add(AddCartEvent(
                                  context: screenContext ?? context,
                                  productId: product.productId,
                                ));
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

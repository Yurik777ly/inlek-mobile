import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';

class ChangeCountProductWidget extends StatelessWidget {
  const ChangeCountProductWidget({
    super.key,
    required this.product,
    this.cartOrProductType = CartOrProductType.product,
    this.screenContext,
  });

  final ProductEntity product;
  final CartOrProductType cartOrProductType;
  final BuildContext? screenContext;

  @override
  Widget build(BuildContext context) {
    final cartBloc = (screenContext ?? context).read<CartScreenBloc>();
    final cartProduct = (cartBloc.state.cartData?.products ?? [])
        .firstWhereOrNull((e) => e.productId == product.productId);
    final isCart = cartOrProductType == CartOrProductType.cart;
    final isProduct = cartOrProductType == CartOrProductType.product;
    int count =
        cartProduct?.availability == 'absent' ? 1 : cartProduct?.quantity ?? 0;
    double? price = cartProduct?.availability == 'absent'
        ? product.price
        : cartProduct?.prices?.price ?? product.price;
    final isAddDisabled = (cartProduct?.quantity ?? 0) >=
        (cartProduct?.stockCount ?? product.stockCount ?? double.infinity);
    final isLoading = (cartProduct ?? product).isLoading;

    if (isProduct && count == 0 && cartProduct?.availability != 'absent') {
      return _AddToCartButton(
          product: product, cartBloc: cartBloc, isLoading: isLoading);
    } else if (isCart) {
      return CartQuantityChanger(
        count: count,
        price: price,
        isAddDisabled: isAddDisabled,
        product: product,
        cartBloc: cartBloc,
        screenContext: screenContext,
      );
    } else {
      return ProductQuantityChanger(
        count: count,
        price: price,
        isAddDisabled: isAddDisabled,
        product: product,
        cartBloc: cartBloc,
        screenContext: screenContext,
      );
    }
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton(
      {required this.product, required this.cartBloc, required this.isLoading});

  final ProductEntity product;
  final CartScreenBloc cartBloc;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => cartBloc.add(AddCartEvent(productId: product.productId!)),
      child: Container(
        height: 44.h,
        padding: getMarginOrPadding(left: 20, right: 20, top: 5.5, bottom: 5.5),
        decoration: BoxDecoration(
          color: UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: UiConstants.pink2Color)
              : Text(
                  'В корзину',
                  style: UiConstants.textStyle3.copyWith(
                    color: UiConstants.whiteColor,
                    height: 1,
                  ),
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
          width: 88.w,
          height: 44.h,
          padding: getMarginOrPadding(all: 8),
          decoration: BoxDecoration(
            color: UiConstants.white2Color,
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Row(
            children: [
              // Минус
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    Paths.minusIconPath,
                    width: 16.w,
                    height: 16.w,
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
                    width: 16.w,
                    height: 16.w,
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
                  onTap: () => cartBloc.add(
                    DeleteCartEvent(
                      context: screenContext ?? context,
                      productId: product.productId!,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: isAddDisabled
                      ? () => ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                          content: Text('Больше нет в наличии'),
                        ))
                      : () => cartBloc.add(
                            AddCartEvent(
                              context: screenContext ?? context,
                              productId: product.productId!,
                            ),
                          ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(8.r),
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
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 44.h,
        padding: getMarginOrPadding(left: 20, right: 20, top: 5.5, bottom: 5.5),
        decoration: BoxDecoration(
          color: UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40.r),
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
                      width: 24.w,
                      height: 24.w,
                      color: UiConstants.whiteColor,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40.r),
                        onTap: () => cartBloc.add(
                          DeleteCartEvent(
                            context: screenContext ?? context,
                            productId: product.productId!,
                          ),
                        ),
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
                      width: 24.w,
                      height: 24.w,
                      color: isAddDisabled
                          ? UiConstants.whiteColor.withOpacity(.4)
                          : UiConstants.whiteColor,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40.r),
                        onTap: isAddDisabled
                            ? () => ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                content: Text('Больше нет в наличии'),
                              ))
                            : () => cartBloc.add(AddCartEvent(
                                  context: screenContext ?? context,
                                  productId: product.productId!,
                                )),
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

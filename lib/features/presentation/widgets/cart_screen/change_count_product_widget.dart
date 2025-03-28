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
import 'package:skeletonizer/skeletonizer.dart';

class ChangeCountProductWidget extends StatelessWidget {
  const ChangeCountProductWidget(
      {super.key,
      required this.product,
      this.cartOrProductType = CartOrProductType.product});

  final ProductEntity product;
  final CartOrProductType cartOrProductType;

  @override
  Widget build(BuildContext context) {
    int count = (context.read<CartScreenBloc>().state.cartData?.products ?? [])
            .firstWhereOrNull((e) => e.productId == product.productId)
            ?.quantity ??
        0;

    return Skeleton.keep(
      child: GestureDetector(
        onTap: cartOrProductType == CartOrProductType.product && count == 0
            ? () => context.read<CartScreenBloc>().add(
                  AddCartEvent(context: context, productId: product.productId!),
                )
            : null,
        child: Container(
          width: cartOrProductType == CartOrProductType.cart ? 88.w : null,
          height: cartOrProductType == CartOrProductType.cart ? null : 44.h,
          padding: cartOrProductType == CartOrProductType.cart
              ? getMarginOrPadding(all: 8)
              : getMarginOrPadding(left: 20, right: 20, top: 5.5, bottom: 5.5),
          decoration: BoxDecoration(
            color: cartOrProductType == CartOrProductType.cart
                ? UiConstants.white2Color
                : UiConstants.purpleColor,
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Align(
            alignment: AlignmentDirectional.center,
            child: Builder(
              builder: (context) {
                if (cartOrProductType == CartOrProductType.product &&
                    count == 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'В корзину',
                        style: (cartOrProductType == CartOrProductType.cart
                                ? UiConstants.textStyle8
                                : UiConstants.textStyle3)
                            .copyWith(color: UiConstants.whiteColor, height: 1),
                      ),
                      if (product.recipe != 'Безрецептурный')
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Только самовывоз',
                              style: UiConstants.textStyle8.copyWith(
                                  color: UiConstants.whiteColor, height: 1),
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.read<CartScreenBloc>().add(
                              DeleteCartEvent(
                                  context: context,
                                  productId: product.productId!),
                            ),
                        child: SvgPicture.asset(
                          Paths.minusIconPath,
                          width: cartOrProductType == CartOrProductType.cart
                              ? 16.w
                              : 24.w,
                          height: cartOrProductType == CartOrProductType.cart
                              ? 16.w
                              : 24.w,
                          color: cartOrProductType == CartOrProductType.cart
                              ? UiConstants.darkBlueColor
                              : UiConstants.whiteColor,
                        ),
                      ),
                      cartOrProductType == CartOrProductType.cart
                          ? Spacer()
                          : SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                count.toString(),
                                style:
                                    (cartOrProductType == CartOrProductType.cart
                                            ? UiConstants.textStyle8
                                            : UiConstants.textStyle3)
                                        .copyWith(
                                            color: cartOrProductType ==
                                                    CartOrProductType.cart
                                                ? UiConstants.darkBlueColor
                                                : UiConstants.whiteColor,
                                            height: 1),
                              ),
                            ),
                            if (cartOrProductType == CartOrProductType.product)
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    Utils.formatPrice(
                                        (product.price ?? 0.0) * count),
                                    style: UiConstants.textStyle8.copyWith(
                                        color: UiConstants.whiteColor
                                            .withOpacity(.6),
                                        height: 1),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      cartOrProductType == CartOrProductType.cart
                          ? Spacer()
                          : SizedBox(width: 3.w),
                      GestureDetector(
                        onTap: () => context.read<CartScreenBloc>().add(
                              AddCartEvent(
                                  context: context,
                                  productId: product.productId!),
                            ),
                        child: SvgPicture.asset(Paths.plusIconPath,
                            width: cartOrProductType == CartOrProductType.cart
                                ? 16.w
                                : 24.w,
                            height: cartOrProductType == CartOrProductType.cart
                                ? 16.w
                                : 24.w,
                            color: cartOrProductType == CartOrProductType.cart
                                ? UiConstants.darkBlueColor
                                : UiConstants.whiteColor),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

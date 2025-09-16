import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';

class ProductPrice extends StatelessWidget {
  final double? oldPrice;
  final double? price;

  final ProductsListScreenType productsListScreenType;

  const ProductPrice(
      {super.key,
      required this.productsListScreenType,
      this.oldPrice,
      this.price});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (oldPrice != null && oldPrice != price && oldPrice != 0)
          Text(
            Utils.formatPrice(oldPrice),
            style: UiConstants.textStyle8.copyWith(
                color: UiConstants.darkBlue2Color.withOpacity(.6),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.lineThrough),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${[
              ProductsListScreenType.cart,
              ProductsListScreenType.order
            ].contains(productsListScreenType) ? '' : 'от '}${Utils.formatPrice(price)}',
            style: UiConstants.textStyle14.copyWith(
                color: oldPrice != null && oldPrice != price && oldPrice != 0
                    ? UiConstants.pink2Color
                    : UiConstants.blackColor),
          ),
        ),
      ],
    );
  }
}

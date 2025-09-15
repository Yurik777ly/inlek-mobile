import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_sale_chip.dart';

class ProductTitleWidget extends StatelessWidget {
  final ProductEntity? product;

  const ProductTitleWidget({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product?.pagetitle ?? '-',
          style:
              UiConstants.textStyle5.copyWith(color: UiConstants.darkBlueColor),
        ),
        SizedBox(height: 8.dp),
        Row(
          children: [
            Text(
              'от ${Utils.formatPrice(product?.price)}',
              style: UiConstants.textStyle9.copyWith(
                  color: product?.oldPrice != null &&
                          product?.oldPrice != product?.price
                      ? UiConstants.pink2Color
                      : UiConstants.blackColor),
            ),
            if ((product?.oldPrice ?? 0) > 0 &&
                product?.oldPrice != product?.price)
              Padding(
                padding: getMarginOrPadding(left: 4),
                child: Text(
                  Utils.formatPrice(product?.oldPrice),
                  style: UiConstants.textStyle8.copyWith(
                    color: UiConstants.darkBlue2Color.withOpacity(.6),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            if ((product?.discount ?? 0) > 0 &&
                (product?.oldPrice ?? 0) > 0 &&
                product?.oldPrice != product?.price)
              Padding(
                padding: getMarginOrPadding(left: 12),
                child: ProductSaleChip(discount: product?.discount ?? 0),
              ),
          ],
        ),
        SizedBox(height: 4.dp),
        Text(
          'Цена может меняться в зависимости от аптеки и способа получения.',
          style: UiConstants.textStyle8.copyWith(
            color: UiConstants.darkBlue2Color.withOpacity(.8),
          ),
        ),
      ],
    );
  }
}

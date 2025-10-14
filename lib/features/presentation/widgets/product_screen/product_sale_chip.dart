import 'package:flutter/material.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductSaleChip extends StatelessWidget {
  final int discount;
  const ProductSaleChip({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    if (discount == 0) return SizedBox.shrink();

    return Skeleton.leaf(
      child: Container(
        padding: getMarginOrPadding(all: 4),
        decoration: BoxDecoration(
          color: UiConstants.pink2Color.withOpacity(.05),
          borderRadius: BorderRadius.circular(200),
        ),
        child: Text(
          '-$discount%',
          style: UiConstants.textStyle6.copyWith(color: UiConstants.pink2Color),
        ),
      ),
    );
  }
}

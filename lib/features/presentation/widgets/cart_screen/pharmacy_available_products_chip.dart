import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';

class PharmacyAvailableProductsChip extends StatelessWidget {
  const PharmacyAvailableProductsChip(
      {super.key,
      required this.allProductsAvailable,
      this.allProductsCount,
      this.availableProductsCount,
      this.isShowAvailableCount = false});

  final bool allProductsAvailable;
  final int? allProductsCount;
  final int? availableProductsCount;
  final bool isShowAvailableCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: getMarginOrPadding(left: 8, right: 8, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: allProductsAvailable
                ? UiConstants.limeColor
                : UiConstants.yellowColor,
            borderRadius: BorderRadius.circular(200.r),
          ),
          child: Text(
            allProductsAvailable
                ? 'В наличии'
                : 'Частично в наличии${isShowAvailableCount ? ' $availableProductsCount из $allProductsCount' : ''}',
            style: UiConstants.textStyle8.copyWith(
              color: UiConstants.darkBlue2Color.withOpacity(.6),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';

class PharmacyAvailableProductsChip extends StatelessWidget {
  const PharmacyAvailableProductsChip(
      {super.key,
      required this.availability,
      this.sumAvailability,
      this.isShowAvailableCount = false});

  final String? availability;
  final String? sumAvailability;
  final bool isShowAvailableCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: getMarginOrPadding(left: 8, right: 8, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: availability == 'full'
                ? UiConstants.limeColor
                : availability == 'part'
                    ? UiConstants.yellowColor
                    : UiConstants.white2Color,
            borderRadius: BorderRadius.circular(200.r),
          ),
          child: Text(
            availability == 'full'
                ? 'В наличии'
                : availability == 'part'
                    ? 'Частично в наличии${isShowAvailableCount ? ' $sumAvailability' : ''}'
                    : 'Нет в наличии',
            style: UiConstants.textStyle8.copyWith(
              color: UiConstants.darkBlue2Color.withOpacity(.6),
            ),
          ),
        ),
      ],
    );
  }
}

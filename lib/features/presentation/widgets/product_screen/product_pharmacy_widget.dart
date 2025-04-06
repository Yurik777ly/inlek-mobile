import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductPharmacyWidget extends StatelessWidget {
  const ProductPharmacyWidget({super.key, required this.pharmacy});

  final PharmacyEntity pharmacy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(top: 16, bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (pharmacy.pharmacyDelivery == 'Доставка')
                Skeleton.replace(
                  child: Container(
                    margin: getMarginOrPadding(right: 9),
                    height: 24.w,
                    width: 24.w,
                    padding: getMarginOrPadding(all: 4),
                    decoration: BoxDecoration(
                        color: UiConstants.purple3Color,
                        shape: BoxShape.circle),
                    child: SvgPicture.asset(Paths.carIconPath,
                        height: double.infinity, width: double.infinity),
                  ),
                ),
              Expanded(
                child: Text(
                  pharmacy.pharmacyDelivery == 'Доставка'
                      ? 'Доставка'
                      : pharmacy.pharmacyName ?? '-',
                  style: UiConstants.textStyle3.copyWith(
                      color: UiConstants.darkBlueColor,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            pharmacy.address ?? '-',
            style: UiConstants.textStyle2
                .copyWith(color: UiConstants.darkBlueColor),
          ),
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: Text(
              pharmacy.expirationDate ?? '-',
              style: UiConstants.textStyle8.copyWith(
                color: UiConstants.darkBlueColor.withOpacity(.6),
              ),
            ),
          ),
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'В наличии ${pharmacy.stockCount} шт.',
                    style: UiConstants.textStyle2.copyWith(
                        color: UiConstants.darkBlueColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '1 шт.',
                      style: UiConstants.textStyle8.copyWith(
                        color: UiConstants.darkBlue2Color.withOpacity(.6),
                      ),
                    ),
                    Text(
                      Utils.formatPrice(pharmacy.price),
                      style: UiConstants.textStyle5
                          .copyWith(color: UiConstants.darkBlueColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

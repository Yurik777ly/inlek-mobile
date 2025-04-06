import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';

class AddressPlate extends StatelessWidget {
  final PharmacyEntity pharmacy;
  final Function() onClose;

  const AddressPlate(
      {super.key, required this.pharmacy, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final String address = pharmacy.address ?? '';
    final List<String> addressSplit = address.split(', ');

    String city = '';
    String street = '';

    if (addressSplit.length > 1) {
      city = addressSplit.first;
      street = addressSplit.skip(1).join(', ');
    }

    return Container(
      padding: getMarginOrPadding(all: 8),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withOpacity(.9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: UiConstants.textStyle5
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                SizedBox(height: 8.h),
                Text(
                  street,
                  style: UiConstants.textStyle2
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onClose,
            child: SvgPicture.asset(
              Paths.closeIconPath,
              width: 24.w,
              height: 24.w,
              color: UiConstants.darkBlue2Color.withOpacity(.6),
            ),
          ),
        ],
      ),
    );
  }
}

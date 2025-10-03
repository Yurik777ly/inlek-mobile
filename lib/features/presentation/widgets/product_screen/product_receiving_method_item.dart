import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/right_arrow_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductReceivingMethodItem extends StatelessWidget {
  const ProductReceivingMethodItem(
      {super.key,
      required this.title,
      required this.subtitle,
      this.onTapArrowButton,
      this.onTap,
      this.isLoading = false});

  final String title;
  final String subtitle;
  final bool isLoading;
  final Function()? onTapArrowButton;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: !isLoading ? onTap : null,
        child: Container(
          padding: getMarginOrPadding(all: 8),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: UiConstants.textStyle3.copyWith(
                      color: UiConstants.darkBlue2Color.withOpacity(.6),
                    ),
                  ),
                  Skeleton.unite(
                    child: Text(
                      subtitle,
                      style: UiConstants.textStyle3.copyWith(
                          color: UiConstants.darkBlueColor,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              if (onTapArrowButton != null)
                RightArrowButton(
                    width: 35,
                    height: 35,
                    padding: getMarginOrPadding(all: 4),
                    onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

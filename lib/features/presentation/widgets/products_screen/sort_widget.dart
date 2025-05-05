import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/products_screen/sort_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SortWidget extends StatelessWidget {
  const SortWidget(
      {super.key,
      required this.onTap,
      required this.caption,
      required this.iconPath});

  final String caption;
  final String iconPath;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Skeleton.ignorePointer(
      child: Skeleton.leaf(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: getMarginOrPadding(left: 8, top: 8, bottom: 8, right: 16),
            decoration: BoxDecoration(
              color: UiConstants.whiteColor,
              borderRadius: BorderRadius.circular(200.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SortButton(onTap: onTap, iconPath: iconPath),
                SizedBox(width: 8.w),
                Text(
                  caption,
                  style: UiConstants.textStyle3
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

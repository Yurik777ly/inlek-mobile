import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/right_arrow_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderInfoItem extends StatelessWidget {
  const OrderInfoItem({
    super.key,
    required this.imagePath,
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.imageForegroundColor,
    this.imageBackgroundColor,
    this.onTap,
    this.showArrow = true,
    this.subtitleWidget,
  });

  final String imagePath;
  final String? title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? imageForegroundColor;
  final Color? imageBackgroundColor;
  final Function()? onTap;
  final bool showArrow;
  final Widget? subtitleWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment:
                  [title, subtitle ?? subtitleWidget].any((e) => e == null)
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
              children: [
                Skeleton.unite(
                  child: Container(
                    height: 40.dp,
                    width: 40.dp,
                    padding: getMarginOrPadding(all: 12),
                    decoration: BoxDecoration(
                      color: imageBackgroundColor ?? UiConstants.white2Color,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SvgPicture.asset(
                      imagePath,
                      colorFilter: ColorFilter.mode(
                          imageForegroundColor ??
                              UiConstants.darkBlueColor.withOpacity(.4),
                          BlendMode.srcIn),
                      height: double.infinity,
                    ),
                  ),
                ),
                SizedBox(width: 8.dp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Padding(
                          padding: getMarginOrPadding(bottom: 4),
                          child: Text(
                            title ?? '',
                            style: titleStyle ??
                                UiConstants.textStyle8.copyWith(
                                  color: UiConstants.darkBlue2Color
                                      .withOpacity(.6),
                                ),
                          ),
                        ),
                      subtitleWidget ??
                          Text(
                            subtitle ?? '',
                            softWrap: true,
                            maxLines: 100,
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle ??
                                UiConstants.textStyle3
                                    .copyWith(color: UiConstants.darkBlueColor),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null && showArrow)
            RightArrowButton(color: UiConstants.whiteColor, onTap: onTap)
        ],
      ),
    );
  }
}

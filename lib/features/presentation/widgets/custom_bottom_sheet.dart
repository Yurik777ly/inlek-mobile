import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet(
      {super.key, this.height, required this.child, this.color, this.padding});

  final double? height;
  final Color? color;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: height,
        width: double.infinity,
        padding: padding ??
            getMarginOrPadding(
                left: 20,
                right: 20,
                top: 8,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: color ?? UiConstants.whiteColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 56,
              decoration: BoxDecoration(
                color: UiConstants.white4Color,
                borderRadius: BorderRadius.circular(200.r),
              ),
            ),
            SizedBox(height: 16),
            child
          ],
        ),
      ),
    );
  }
}

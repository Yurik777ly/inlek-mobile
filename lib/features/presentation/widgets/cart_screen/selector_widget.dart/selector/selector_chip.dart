import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';

class SelectorChip extends StatelessWidget {
  final String text;
  final bool selected;
  final bool isUnavailable;
  final int index;
  final Function(int index) onTap;

  const SelectorChip(
      {required this.text,
      required this.selected,
      required this.isUnavailable,
      required this.index,
      super.key,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: !isUnavailable ? () => onTap(index) : null,
        child: Container(
          padding: getMarginOrPadding(top: 10, bottom: 10),
          alignment: Alignment.center,
          margin: getMarginOrPadding(left: index != 0 ? 2 : 0),
          decoration: BoxDecoration(
            color: selected ? UiConstants.purpleColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(text,
              style: UiConstants.textStyle2.copyWith(
                  fontSize: 15.dp,
                  color: selected
                      ? UiConstants.whiteColor
                      : isUnavailable
                          ? UiConstants.mutedVioletColor
                          : UiConstants.darkBlueColor),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

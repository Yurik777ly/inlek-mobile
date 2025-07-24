import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomRadioButton extends StatelessWidget {
  const CustomRadioButton({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.textStyle,
    this.isLabelOnLeft = false,
    this.isAvailable = true,
  });

  final String title;
  final dynamic value;
  final dynamic groupValue;
  final Function() onChanged;
  final TextStyle? textStyle;
  final bool isLabelOnLeft;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? () => onChanged() : null,
      child: Skeleton.unite(
        child: Card(
          margin: EdgeInsets.zero,
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: isLabelOnLeft
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: isLabelOnLeft
                ? [
                    _buildLabel(),
                    _buildRadio(),
                  ]
                : [
                    _buildRadio(),
                    _buildLabel(),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadio() {
    return Transform.scale(
      scale: 1.5,
      child: SizedBox(
        height: 24.dp,
        width: 24.dp,
        child: RadioTheme(
          data: RadioThemeData(
            fillColor: WidgetStatePropertyAll(
              UiConstants.darkBlueColor.withOpacity(.3),
            ),
          ),
          child: Radio<dynamic>(
            value: value,
            groupValue: groupValue,
            toggleable: true,
            overlayColor: WidgetStateProperty.all(
              UiConstants.darkBlueColor.withOpacity(.3),
            ),
            activeColor: UiConstants.purpleColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: isAvailable ? (value) => onChanged() : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: getMarginOrPadding(left: 4),
      child: Text(
        title,
        style: (textStyle ?? UiConstants.textStyle11)
            .copyWith(color: UiConstants.darkBlueColor),
      ),
    );
  }
}

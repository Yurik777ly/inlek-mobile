import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox(
      {super.key,
      this.title,
      required this.isChecked,
      required this.onChanged,
      this.spacing,
      this.textStyle,
      this.borderRadius,
      this.scale = 1.5,
      this.isEnabled = true,
      this.showError = false});

  final Widget? title;
  final bool isChecked;
  final Function(bool?) onChanged;
  final double? spacing;
  final TextStyle? textStyle;
  final double? borderRadius;
  final double scale;
  final bool isEnabled;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => isEnabled ? onChanged(!isChecked) : null,
          child: Skeleton.unite(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                    isChecked
                        ? Paths.checkboxActiveIconPath
                        : Paths.checkboxInactiveIconPath,
                    height: 24,
                    width: 24),
                if (title != null)
                  Expanded(
                    child: Padding(
                        padding: getMarginOrPadding(left: spacing ?? 8),
                        child: title),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

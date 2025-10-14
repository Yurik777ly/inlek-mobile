import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';

class AddressPlate extends StatelessWidget {
  final String title;
  final String body;
  final Function()? onClose;

  const AddressPlate(
      {super.key, required this.title, required this.body, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(all: 8),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withOpacity(.9),
        borderRadius: BorderRadius.circular(8),
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
                  title,
                  style: UiConstants.textStyle5
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                SizedBox(height: 8),
                Text(
                  body,
                  style: UiConstants.textStyle2
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
              ],
            ),
          ),
          if (onClose != null)
            Padding(
              padding: getMarginOrPadding(left: 8),
              child: GestureDetector(
                onTap: onClose,
                child: SvgPicture.asset(
                  Paths.closeIconPath,
                  width: 24,
                  height: 24,
                  color: UiConstants.darkBlue2Color.withOpacity(.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

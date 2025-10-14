import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';

class PrescriptionWidget extends StatelessWidget {
  const PrescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(Paths.infoIconPath,
                color: UiConstants.pink2Color, width: 16.w, height: 16.h),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'По рецепту, доступен только самовывоз из аптеки',
                style: UiConstants.textStyle8.copyWith(
                    color: UiConstants.pink2Color, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        8.ph,
        Container(
          padding: getMarginOrPadding(all: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: UiConstants.pink3Color, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Это рецептурный препарат!',
                style: UiConstants.textStyle8.copyWith(
                    color: UiConstants.darkBlueColor,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                'Можно получить только в аптеке по рецепту врача, доступен только самовывоз из аптеки',
                style: UiConstants.textStyle8
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

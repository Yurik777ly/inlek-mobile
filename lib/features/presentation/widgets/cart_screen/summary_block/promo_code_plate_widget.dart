import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class PromoCodePlateWidget extends StatelessWidget {
  const PromoCodePlateWidget(
      {super.key, required this.onDelete, required this.promocodeEntity});

  final PromocodeEntity promocodeEntity;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(left: 16, right: 16, top: 8, bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(Paths.promoCodeBackgroundIconPath),
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promocodeEntity.promocode,
                style: UiConstants.textStyle3.copyWith(
                    color: UiConstants.purpleColor,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                'Скидка ${promocodeEntity.promocodePercent}%',
                style: UiConstants.textStyle8.copyWith(
                  color: UiConstants.darkBlue2Color.withOpacity(.6),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onDelete,
            child: SvgPicture.asset(Paths.closeIconPath, width: 24, height: 24),
          )
        ],
      ),
    );
  }
}

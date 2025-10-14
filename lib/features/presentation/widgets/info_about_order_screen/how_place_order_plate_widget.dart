import 'package:flutter/material.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/pages/profile/how_place_order_screen.dart';
import 'package:inlek/features/presentation/widgets/right_arrow_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HowPlaceOrderPlateWidget extends StatelessWidget {
  const HowPlaceOrderPlateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton.ignorePointer(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          Routes.createRoute(
            const HowPlaceOrderScreen(),
            settings: RouteSettings(name: Routes.howPlaceOrderScreen),
          ),
        ),
        child: Container(
          padding: getMarginOrPadding(left: 16, right: 16, top: 8, bottom: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(Paths.howPlaceOrderBackgroundIconPath),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Как сделать заказ через приложение?',
                      style: UiConstants.textStyle3.copyWith(
                          color: UiConstants.purpleColor,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Подробно рассказали здесь',
                      style: UiConstants.textStyle8.copyWith(
                        color: UiConstants.darkBlue2Color.withOpacity(.6),
                      ),
                    ),
                  ],
                ),
              ),
              RightArrowButton(color: Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/pages/profile/sales/sales_screen.dart';

class StocksPlateWidget extends StatelessWidget {
  const StocksPlateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(
          Routes.createRoute(
            const SalesScreen(),
            settings: RouteSettings(name: Routes.salesScreen),
          ),
        );
      },
      child: Container(
        padding: getMarginOrPadding(left: 21),
        height: 76,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(Paths.stocksBackgroundIconPath),
            ),
            borderRadius: BorderRadius.circular(16)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Акции',
            style: UiConstants.textStyle5
                .copyWith(color: UiConstants.darkBlueColor),
          ),
        ),
      ),
    );
  }
}

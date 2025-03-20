import 'package:flutter/material.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/right_arrow_button.dart';

class OnlinePaymentMethodButton extends StatelessWidget {
  const OnlinePaymentMethodButton(
      {super.key, required this.child, required this.onTap});

  final Widget child;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        backgroundColor: WidgetStatePropertyAll(UiConstants.whiteColor),
        elevation: WidgetStatePropertyAll(0),
        padding: WidgetStatePropertyAll(
          getMarginOrPadding(top: 12, bottom: 12, left: 8, right: 20),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          child,
          RightArrowButton(),
        ],
      ),
    );
  }
}

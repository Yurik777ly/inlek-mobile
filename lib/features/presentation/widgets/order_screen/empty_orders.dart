import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';

class EmptyOrders extends StatelessWidget {
  const EmptyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getMarginOrPadding(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заказов пока нет',
            style: UiConstants.textStyle9.copyWith(
              color: UiConstants.blackColor,
            ),
          ),
          SizedBox(height: 39.h),
          Image.asset(
            Paths.emptyOrdersIconPath,
          ),
          Spacer(),
          AppButtonWidget(
            isActive: true,
            text: 'За покупками',
            onTap: () {
              //Navigator.pop(context);
              context.read<HomeScreenBloc>().add(
                    ChangePageEvent(1, forcePopToRoot: true),
                  );
            },
          ),
        ],
      ),
    );
  }
}

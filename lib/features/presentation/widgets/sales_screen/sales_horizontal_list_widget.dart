import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/presentation/widgets/sales_screen/sales_list_item.dart';

class SalesHorizontalListWidget extends StatelessWidget {
  const SalesHorizontalListWidget({super.key, required this.actions});

  final List<ActionEntity> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 235.w,
      child: actions.length == 1
          ? SalesListItem(action: actions.first, isOneElementInList: true)
          : ListView.separated(
              padding: getMarginOrPadding(left: 20, right: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => SalesListItem(
                    action: actions[index],
                  ),
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemCount: actions.length),
    );
  }
}

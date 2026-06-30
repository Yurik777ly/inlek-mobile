import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderItemStatusChip extends StatelessWidget {
  const OrderItemStatusChip({
    super.key,
    required this.orderStatus,
    this.compact = false,
  });

  final OrderStatus orderStatus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(
        left: compact ? 6 : 8,
        right: compact ? 6 : 8,
        top: compact ? 2 : 4,
        bottom: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: UiConstants.white5Color,
        borderRadius: BorderRadius.circular(200),
      ),
      child: Row(
        children: [
          Skeleton.unite(
            child: CircleAvatar(
              radius: compact ? 3 : 3.r,
              backgroundColor: [OrderStatus.canceled].contains(orderStatus)
                  ? UiConstants.darkBlue2Color.withOpacity(.8)
                  : UiConstants.greenColor,
            ),
          ),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              Utils.getRussianOrderStatus(orderStatus),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiConstants.textStyle6.copyWith(
                color: UiConstants.darkBlue2Color.withOpacity(.8),
                height: compact ? 1.1 : null,
                fontSize: compact ? 9 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

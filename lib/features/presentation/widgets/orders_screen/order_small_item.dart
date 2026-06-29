import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_item_status_chip.dart';
import 'package:inlek/features/presentation/widgets/right_arrow_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderSmallItem extends StatelessWidget {
  final VoidCallback onTapOrder;
  const OrderSmallItem(
      {super.key, required this.order, required this.onTapOrder});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Skeleton.ignorePointer(
      child: GestureDetector(
        onTap: onTapOrder,
        child: Container(
          width: 148,
          padding: getMarginOrPadding(all: 8),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.typeReceipt?.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiConstants.textStyle8.copyWith(
                  color: UiConstants.darkBlueColor.withOpacity(.6),
                ),
              ),
              Text(
                'Заказ #${order.orderId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiConstants.textStyle3.copyWith(
                    color: UiConstants.darkBlueColor,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                Utils.formatDate(order.createdAt ?? DateTime.now()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiConstants.textStyle8.copyWith(
                  color: UiConstants.darkBlue2Color.withOpacity(.6),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (order.status != null)
                    Expanded(
                      child: OrderItemStatusChip(orderStatus: order.status!),
                    ),
                  8.pw,
                  RightArrowButton(height: 22, width: 22),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

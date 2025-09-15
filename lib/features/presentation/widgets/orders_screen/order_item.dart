import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_item_products_list.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_item_status_chip.dart';
import 'package:inlek/features/presentation/widgets/right_arrow_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderItem extends StatelessWidget {
  final VoidCallback onTapOrder;
  const OrderItem({super.key, required this.order, required this.onTapOrder});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Skeleton.ignorePointer(
      child: GestureDetector(
        onTap: onTapOrder,
        child: Container(
          padding: getMarginOrPadding(all: 8),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.typeReceipt?.title ?? '',
                        style: UiConstants.textStyle8.copyWith(
                          color: UiConstants.darkBlueColor.withOpacity(.6),
                        ),
                      ),
                      Text(
                        'Заказ #${order.orderId}',
                        style: UiConstants.textStyle3.copyWith(
                            color: UiConstants.darkBlueColor,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 8.dp),
                      Text(
                        Utils.formatDate(order.createdAt!),
                        style: UiConstants.textStyle3.copyWith(
                          color: UiConstants.darkBlue2Color.withOpacity(.6),
                        ),
                      ),
                      SizedBox(height: 8.dp),
                      OrderItemStatusChip(orderStatus: order.status!)
                    ],
                  ),
                  RightArrowButton(),
                ],
              ),
              SizedBox(height: 8.dp),
              OrderItemProductsList(orderProducts: order.products ?? [])
            ],
          ),
        ),
      ),
    );
  }
}

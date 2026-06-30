import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/presentation/bloc/orders_screen/orders_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/profile/orders/order_screen.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_small_item.dart';

class OrdersListWidget extends StatelessWidget {
  final List<OrderEntity> orders;

  const OrdersListWidget({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
          padding: getMarginOrPadding(left: 20, right: 20),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => OrderSmallItem(
                order: orders[index],
                onTapOrder: () async {
                  await Navigator.of(context).push(
                    Routes.createRoute(
                      const OrderScreen(),
                      settings: RouteSettings(
                          name: Routes.orderScreen,
                          arguments: orders[index].orderId),
                    ),
                  );
                  if (context.mounted) {
                    context.read<OrdersScreenBloc>().add(LoadDataEvent());
                  }
                },
              ),
          separatorBuilder: (context, index) => SizedBox(width: 8),
          itemCount: orders.length),
    );
  }
}

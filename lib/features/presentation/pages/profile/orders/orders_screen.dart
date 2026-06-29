import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/orders_screen/orders_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/profile/orders/order_screen.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/custom_checkbox.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/order_screen/empty_orders.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_item.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrdersScreenBloc>().add(const ResetAndLoadOrdersEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        return BlocBuilder<OrdersScreenBloc, OrdersScreenState>(
          builder: (context, ordersState) {
            final ordersBloc = context.read<OrdersScreenBloc>();
            final orders = ordersBloc.getVisibleOrders();
            final homeContext = UiConstants.homeContext ?? context;

            return Scaffold(
              backgroundColor: UiConstants.backgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    CustomAppBar(
                      hintText: 'Искать по заказам',
                      controller: ordersBloc.queryController,
                      title: 'История заказов',
                      showBack: true,
                      isShowFilterButton: true,
                      onChangedField: (value) =>
                          ordersBloc.add(ChangeQueryEvent(value)),
                      onTapFilterButton: () =>
                          BottomSheetManager.showOrdersFilterSheet(
                        homeContext,
                        context,
                      ),
                    ),
                    Expanded(
                      child: homeState is InternetUnavailable
                          ? InternetNoInternetConnectionWidget()
                          : Padding(
                              padding: getMarginOrPadding(
                                bottom: 94,
                                right: 20,
                                left: 20,
                                top: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomCheckbox(
                                    title: Text(
                                      'Только активные',
                                      style: UiConstants.textStyle2.copyWith(
                                        color: UiConstants.blackColor,
                                      ),
                                    ),
                                    isChecked: ordersState.isOnlyActive,
                                    onChanged: (checked) => ordersBloc.add(
                                      ChangeOnlyActiveOrdersEvent(checked),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Expanded(
                                    child: _OrdersContent(
                                      ordersState: ordersState,
                                      orders: orders,
                                      onOpenOrder: (order) async {
                                        await Navigator.of(context).push(
                                          Routes.createRoute(
                                            const OrderScreen(),
                                            settings: RouteSettings(
                                              name: Routes.orderScreen,
                                              arguments: order.orderId,
                                            ),
                                          ),
                                        );

                                        ordersBloc.add(
                                          const ResetAndLoadOrdersEvent(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({
    required this.ordersState,
    required this.orders,
    required this.onOpenOrder,
  });

  final OrdersScreenState ordersState;
  final List<OrderEntity> orders;
  final Future<void> Function(OrderEntity order) onOpenOrder;

  String _emptyMessage() {
    if (ordersState.query.isNotEmpty) {
      return 'Проверьте правильность номера заказа';
    }

    if (ordersState.isOnlyActive && ordersState.orders.isNotEmpty) {
      return 'Нет активных заказов';
    }

    if (ordersState.hasActiveFilters) {
      return 'По выбранным фильтрам заказов нет';
    }

    return 'Заказов пока нет';
  }

  @override
  Widget build(BuildContext context) {
    if (ordersState.isLoading && ordersState.orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: UiConstants.pink2Color,
        ),
      );
    }

    if (ordersState.orders.isEmpty &&
        !ordersState.hasActiveFilters &&
        !ordersState.isOnlyActive) {
      return const EmptyOrders();
    }

    if (orders.isEmpty) {
      return Center(
        child: Text(
          _emptyMessage(),
          textAlign: TextAlign.center,
          style: UiConstants.textStyle3.copyWith(
            color: UiConstants.darkBlueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: orders.length,
      separatorBuilder: (_, __) => SizedBox(height: 8),
      itemBuilder: (context, index) => OrderItem(
        order: orders[index],
        onTapOrder: () => onOpenOrder(orders[index]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/orders_screen/orders_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/custom_checkbox.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/order_screen/empty_orders.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_item.dart';
import 'package:inlek/locator_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        return BlocProvider(
          create: (context) =>
              OrdersScreenBloc(getOrderHistoryUC: sl())..add(LoadDataEvent()),
          child: BlocBuilder<OrdersScreenBloc, OrdersScreenState>(
            builder: (context, ordersState) {
              final ordersBloc = context.read<OrdersScreenBloc>();

              // Отфильтрованный и отсортированный список заказов
              List<OrderEntity> orders = List.from(ordersState.filteredOrders)
                ..sort((a, b) => b.orderId!.compareTo(a.orderId!));

              if (ordersState.isOnlyActive) {
                orders = orders
                    .where((e) => e.status != OrderStatus.canceled)
                    .toList();
              }

              return Scaffold(
                backgroundColor: UiConstants.backgroundColor,
                body: SafeArea(
                  child: Skeletonizer(
                    enabled: ordersState.isLoading,
                    ignorePointers: false,
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
                                  UiConstants.homeContext!, context),
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
                                    children: [
                                      CustomCheckbox(
                                        title: Text(
                                          'Только активные',
                                          style:
                                              UiConstants.textStyle2.copyWith(
                                            color: UiConstants.blackColor,
                                          ),
                                        ),
                                        isChecked: ordersState.isOnlyActive,
                                        onChanged: (checked) => ordersBloc.add(
                                          ChangeOnlyActiveOrdersEvent(checked),
                                        ),
                                      ),
                                      SizedBox(height: 16.dp),

                                      // Контент заказов с учётом состояний
                                      Expanded(
                                        child: ordersState.orders.isEmpty
                                            ? EmptyOrders()
                                            : orders.isEmpty
                                                ? Center(
                                                    child: Text(
                                                      ordersState
                                                              .query.isNotEmpty
                                                          ? 'Проверьте правильность номера заказа'
                                                          : 'По выбранным фильтрам заказов нет',
                                                      style: UiConstants
                                                          .textStyle3
                                                          .copyWith(
                                                        color: UiConstants
                                                            .darkBlueColor,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  )
                                                : ListView.separated(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount: orders.length,
                                                    separatorBuilder: (_, __) =>
                                                        SizedBox(height: 8.dp),
                                                    itemBuilder: (context,
                                                            index) =>
                                                        OrderItem(
                                                            order:
                                                                orders[index]),
                                                  ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/domain/usecases/orders/get_order_history.dart';

part 'orders_screen_event.dart';
part 'orders_screen_state.dart';

class OrdersScreenBloc extends Bloc<OrdersScreenEvent, OrdersScreenState> {
  final GetOrderHistoryUC getOrderHistoryUC;

  TextEditingController queryController = TextEditingController();

  OrdersScreenBloc({required this.getOrderHistoryUC})
      : super(
          OrdersScreenState(
            isOnlyActive: false,
            typesReceiving: ['Доставка', 'Самовывоз'],
            selectedTypesReceivingIds: {},
            selectedStatuses: {},
          ),
        ) {
    on<LoadDataEvent>(_onLoadData);
    on<ChangeOnlyActiveOrdersEvent>(_onChangeOnlyActiveOrdersEvent);
    on<SelectTypeReceivingEvent>(_onSelectTypeReceivingEvent);
    on<SelectStatusEvent>(_onSelectStatusEvent);
    on<SelectDateEvent>(_onSelectDateEvent);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFilterEvent>(_onClearEvent);
    on<ChangeQueryEvent>(_onChangeQuery);
  }

  void _onLoadData(LoadDataEvent event, Emitter<OrdersScreenState> emit) async {
    final failureOrLoads = await getOrderHistoryUC();

    failureOrLoads.fold(
      (_) => emit(
        state.copyWith(isLoading: false, error: 'Ошибка загрузки данных'),
      ),
      (history) {
        List<OrderEntity> filteredOrders = getFilteredOrders(history);

        emit(
          state.copyWith(
              error: null,
              isLoading: false,
              orders: history,
              filteredOrders: filteredOrders),
        );
      },
    );
  }

  void _onChangeOnlyActiveOrdersEvent(
      ChangeOnlyActiveOrdersEvent event, Emitter<OrdersScreenState> emit) {
    emit(state.copyWith(isOnlyActive: event.isChecked));
  }

  void _onSelectTypeReceivingEvent(
      SelectTypeReceivingEvent event, Emitter<OrdersScreenState> emit) {
    final updatedTypesReceivingIds =
        Set<int>.from(state.selectedTypesReceivingIds);
    if (event.isChecked == true) {
      updatedTypesReceivingIds.add(event.typeReceivingId);
    } else {
      updatedTypesReceivingIds.remove(event.typeReceivingId);
    }
    emit(state.copyWith(selectedTypesReceivingIds: updatedTypesReceivingIds));
  }

  void _onSelectStatusEvent(
      SelectStatusEvent event, Emitter<OrdersScreenState> emit) {
    final updatedStatusesIds = Set<OrderStatus>.from(state.selectedStatuses);
    if (event.isChecked == true) {
      updatedStatusesIds.add(event.status);
    } else {
      updatedStatusesIds.remove(event.status);
    }
    emit(state.copyWith(selectedStatuses: updatedStatusesIds));
  }

  void _onSelectDateEvent(
      SelectDateEvent event, Emitter<OrdersScreenState> emit) {
    emit(state.copyWith());
  }

  void _onApplyFilters(
      ApplyFiltersEvent event, Emitter<OrdersScreenState> emit) {
    emit(
      state.copyWith(
          selectedTypesReceivingIds: event.selectedTypesReceivingIds,
          selectedStatuses: event.selectedStatuses,
          startDate: event.startDate,
          endDate: event.endDate),
    );

    List<OrderEntity> filteredOrders = getFilteredOrders(state.orders);

    emit(state.copyWith(filteredOrders: filteredOrders));
  }

  List<OrderEntity> getFilteredOrders(List<OrderEntity> orders) {
    List<OrderEntity> filteredOrders = List.of(orders);

    if (state.query.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((e) => e.orderId.toString().startsWith(state.query))
          .toList();
    }

    if (state.selectedStatuses.isNotEmpty) {
      filteredOrders = filteredOrders
          .where(
            (e) => state.selectedStatuses.contains(e.status),
          )
          .toList();
    }

    if (state.selectedTypesReceivingIds.isNotEmpty) {
      filteredOrders = filteredOrders
          .where(
            (e) => state.selectedTypesReceivingIds.contains(
              state.typesReceiving.indexOf(e.deliveryTitle == 'Самовывоз'
                  ? e.deliveryTitle!
                  : 'Доставка'),
            ),
          )
          .toList();
    }

    DateTime startDate = state.startDate ?? DateTime(DateTime.now().year, 1, 1);
    DateTime endDate = state.endDate ?? DateTime(DateTime.now().year, 12, 31);

    final adjustedEndDate =
        endDate.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

    filteredOrders = filteredOrders
        .where((e) =>
            e.createdAt!.isAfter(startDate) &&
            e.createdAt!.isBefore(adjustedEndDate))
        .toList();

    return filteredOrders;
  }

  void _onClearEvent(ClearFilterEvent event, Emitter<OrdersScreenState> emit) {
    DateTime startDate = state.startDate ?? DateTime(DateTime.now().year, 1, 1);
    DateTime endDate = state.endDate ?? DateTime(DateTime.now().year, 12, 31);
    emit(state.copyWith(
        selectedTypesReceivingIds: {},
        selectedStatuses: {},
        startDate: startDate,
        endDate: endDate));
  }

  void _onChangeQuery(ChangeQueryEvent event, Emitter<OrdersScreenState> emit) {
    emit(state.copyWith(query: event.query));
    add(ApplyFiltersEvent());
  }
}

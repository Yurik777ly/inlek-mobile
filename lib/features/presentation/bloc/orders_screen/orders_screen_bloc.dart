import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
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
    on<ResetAndLoadOrdersEvent>(_onResetAndLoad);
    on<ChangeOnlyActiveOrdersEvent>(_onChangeOnlyActiveOrdersEvent);
    on<SelectTypeReceivingEvent>(_onSelectTypeReceivingEvent);
    on<SelectStatusEvent>(_onSelectStatusEvent);
    on<SelectDateEvent>(_onSelectDateEvent);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFilterEvent>(_onClearEvent);
    on<ChangeQueryEvent>(_onChangeQuery);
  }

  void _onLoadData(LoadDataEvent event, Emitter<OrdersScreenState> emit) async {
    await _loadOrders(
      emit,
      state,
      showLoader: state.orders.isEmpty,
    );
  }

  Future<void> _onResetAndLoad(
    ResetAndLoadOrdersEvent event,
    Emitter<OrdersScreenState> emit,
  ) async {
    queryController.clear();
    final hadOrders = state.orders.isNotEmpty;
    final cleanState = state.copyWith(
      query: '',
      selectedTypesReceivingIds: {},
      selectedStatuses: {},
      startDate: null,
      endDate: null,
      isOnlyActive: false,
      error: null,
      isLoading: !hadOrders,
    );
    emit(cleanState);
    await _loadOrders(emit, cleanState, showLoader: !hadOrders);
  }

  Future<void> _loadOrders(
    Emitter<OrdersScreenState> emit,
    OrdersScreenState baseState, {
    bool showLoader = false,
  }) async {
    if (showLoader) {
      emit(baseState.copyWith(isLoading: true));
    }

    final failureOrLoads = await getOrderHistoryUC();
    if (emit.isDone) return;

    failureOrLoads.fold(
      (_) => emit(
        baseState.copyWith(
          isLoading: false,
          error: 'Ошибка загрузки данных',
        ),
      ),
      (history) {
        final filteredOrders = _filterOrders(history, baseState);

        emit(
          baseState.copyWith(
            error: null,
            isLoading: false,
            orders: history,
            filteredOrders: filteredOrders,
          ),
        );
      },
    );
  }

  void _onChangeOnlyActiveOrdersEvent(
      ChangeOnlyActiveOrdersEvent event, Emitter<OrdersScreenState> emit) {
    emit(state.copyWith(isOnlyActive: event.isChecked ?? false));
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
    final nextState = state.copyWith(
      selectedTypesReceivingIds: event.selectedTypesReceivingIds,
      selectedStatuses: event.selectedStatuses,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    emit(
      nextState.copyWith(
        filteredOrders: _filterOrders(nextState.orders, nextState),
      ),
    );
  }

  List<OrderEntity> getFilteredOrders(List<OrderEntity> orders) {
    return _filterOrders(orders, state);
  }

  List<OrderEntity> _filterOrders(
    List<OrderEntity> orders,
    OrdersScreenState filterState,
  ) {
    List<OrderEntity> filteredOrders = List.of(orders);

    if (filterState.query.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((e) => e.orderId.toString().startsWith(filterState.query))
          .toList();
    }

    if (filterState.selectedStatuses.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((e) => filterState.selectedStatuses.contains(e.status))
          .toList();
    }

    if (filterState.selectedTypesReceivingIds.isNotEmpty) {
      filteredOrders = filteredOrders.where((e) {
        final typeTitle = e.typeReceipt == TypeReceiving.pickup
            ? TypeReceiving.pickup.title
            : TypeReceiving.delivery.title;
        final typeIndex = filterState.typesReceiving.indexOf(typeTitle);
        return typeIndex >= 0 &&
            filterState.selectedTypesReceivingIds.contains(typeIndex);
      }).toList();
    }

    if (filterState.startDate != null && filterState.endDate != null) {
      final adjustedEndDate = filterState.endDate!
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      filteredOrders = filteredOrders.where((e) {
        final createdAt = e.createdAt;
        if (createdAt == null) {
          return true;
        }

        return !createdAt.isBefore(filterState.startDate!) &&
            !createdAt.isAfter(adjustedEndDate);
      }).toList();
    }

    return filteredOrders;
  }

  void _onClearEvent(ClearFilterEvent event, Emitter<OrdersScreenState> emit) {
    queryController.clear();
    final clearedState = state.copyWith(
      selectedTypesReceivingIds: {},
      selectedStatuses: {},
      query: '',
      startDate: null,
      endDate: null,
      isOnlyActive: false,
    );
    emit(
      clearedState.copyWith(
        filteredOrders: _filterOrders(clearedState.orders, clearedState),
      ),
    );
  }

  List<OrderEntity> getVisibleOrders() {
    final source =
        state.hasActiveFilters ? state.filteredOrders : state.orders;

    var orders = List<OrderEntity>.from(source)
      ..sort((a, b) => (b.orderId ?? 0).compareTo(a.orderId ?? 0));

    if (state.isOnlyActive) {
      orders = orders
          .where((e) =>
              ![OrderStatus.canceled, OrderStatus.received].contains(e.status))
          .toList();
    }

    return orders;
  }

  void _onChangeQuery(ChangeQueryEvent event, Emitter<OrdersScreenState> emit) {
    final nextState = state.copyWith(query: event.query);
    emit(
      nextState.copyWith(
        filteredOrders: _filterOrders(nextState.orders, nextState),
      ),
    );
  }
}

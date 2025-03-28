part of 'orders_screen_bloc.dart';

class OrdersScreenState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<OrderEntity> orders;
  final List<OrderEntity> filteredOrders;
  final bool isOnlyActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String query;
  final List<String> typesReceiving;
  final Set<int> selectedTypesReceivingIds;
  final Set<OrderStatus> selectedStatuses;

  const OrdersScreenState({
    this.isLoading = true,
    this.error,
    this.isOnlyActive = false,
    this.startDate,
    this.endDate,
    this.orders = const [],
    this.filteredOrders = const [],
    this.query = '',
    this.typesReceiving = const [],
    this.selectedTypesReceivingIds = const {},
    this.selectedStatuses = const {},
  });

  OrdersScreenState copyWith({
    bool? isLoading,
    String? error,
    bool? isOnlyActive,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
    List<OrderEntity>? orders,
    List<OrderEntity>? filteredOrders,
    List<String>? typesReceiving,
    Set<int>? selectedTypesReceivingIds,
    Set<OrderStatus>? selectedStatuses,
  }) {
    return OrdersScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isOnlyActive: isOnlyActive ?? this.isOnlyActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      query: query ?? this.query,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      typesReceiving: typesReceiving ?? this.typesReceiving,
      selectedTypesReceivingIds:
          selectedTypesReceivingIds ?? this.selectedTypesReceivingIds,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        isOnlyActive,
        startDate,
        endDate,
        query,
        orders,
        filteredOrders,
        typesReceiving,
        selectedTypesReceivingIds,
        selectedStatuses,
      ];
}

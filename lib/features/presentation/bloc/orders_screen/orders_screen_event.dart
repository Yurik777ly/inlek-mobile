part of 'orders_screen_bloc.dart';

abstract class OrdersScreenEvent extends Equatable {
  const OrdersScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadDataEvent extends OrdersScreenEvent {}

class ResetAndLoadOrdersEvent extends OrdersScreenEvent {
  const ResetAndLoadOrdersEvent();
}

class ChangeOnlyActiveOrdersEvent extends OrdersScreenEvent {
  final bool? isChecked;
  const ChangeOnlyActiveOrdersEvent(this.isChecked);
}

class SelectTypeReceivingEvent extends OrdersScreenEvent {
  final int typeReceivingId;
  final bool? isChecked;
  const SelectTypeReceivingEvent(this.typeReceivingId, this.isChecked);

  @override
  List<Object> get props => [typeReceivingId, isChecked ?? false];
}

class SelectStatusEvent extends OrdersScreenEvent {
  final OrderStatus status;
  final bool? isChecked;
  const SelectStatusEvent(this.status, this.isChecked);

  @override
  List<Object> get props => [status, isChecked ?? false];
}

class SelectDateEvent extends OrdersScreenEvent {
  final String date;

  const SelectDateEvent(this.date);

  @override
  List<Object> get props => [date];
}

class ApplyFiltersEvent extends OrdersScreenEvent {
  final Set<int>? selectedTypesReceivingIds;
  final Set<OrderStatus>? selectedStatuses;
  final DateTime? startDate;
  final DateTime? endDate;
  const ApplyFiltersEvent(
      {this.selectedTypesReceivingIds,
      this.selectedStatuses,
      this.startDate,
      this.endDate});

  @override
  List<Object?> get props =>
      [selectedTypesReceivingIds, selectedStatuses, startDate, endDate];
}

class ClearFilterEvent extends OrdersScreenEvent {
  const ClearFilterEvent();

  @override
  List<Object> get props => [];
}

class ChangeQueryEvent extends OrdersScreenEvent {
  final String query;

  const ChangeQueryEvent(this.query);

  @override
  List<Object> get props => [query];
}

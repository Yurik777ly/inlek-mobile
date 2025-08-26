part of 'order_screen_bloc.dart';

abstract class OrderScreenEvent extends Equatable {
  const OrderScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadDataEvent extends OrderScreenEvent {
  final int? orderId;
  const LoadDataEvent(this.orderId);
}

class RepeatOrderEvent extends OrderScreenEvent {
  final int orderId;
  final Function(bool isSuccess) callback;
  const RepeatOrderEvent(this.orderId, this.callback);
}

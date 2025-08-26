part of 'order_screen_bloc.dart';

class OrderScreenState extends Equatable {
  final bool isLoading;
  final bool isRepeatingOrder;
  final String? error;
  final OrderEntity? order;

  const OrderScreenState({
    this.isLoading = true,
    this.isRepeatingOrder = false,
    this.error,
    this.order,
  });

  OrderScreenState copyWith({
    bool? isLoading,
    bool? isRepeatingOrder,
    String? error,
    OrderEntity? order,
  }) {
    return OrderScreenState(
      isLoading: isLoading ?? this.isLoading,
      isRepeatingOrder: isRepeatingOrder ?? this.isRepeatingOrder,
      error: error ?? this.error,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRepeatingOrder,
        error,
        order,
      ];
}

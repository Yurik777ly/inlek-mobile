import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/domain/usecases/orders/get_one_order.dart';
import 'package:inlek/features/domain/usecases/orders/repeat_order.dart';

part 'order_screen_event.dart';
part 'order_screen_state.dart';

class OrderScreenBloc extends Bloc<OrderScreenEvent, OrderScreenState> {
  final GetOneOrderUC getOneOrderUC;
  final RepeatOrderUC repeatOrderUC;
  OrderScreenBloc({required this.getOneOrderUC, required this.repeatOrderUC})
      : super(OrderScreenState()) {
    on<LoadOrderEvent>(_onLoadData);
    on<RepeatOrderEvent>(_onRepeatOrderEvent);
  }

  void _onLoadData(LoadOrderEvent event, Emitter<OrderScreenState> emit) async {
    if (event.orderId == null) {
      emit(
        state.copyWith(isLoading: false, error: 'Ошибка загрузки данных'),
      );
    } else {
      final failureOrLoads = await getOneOrderUC(event.orderId!);

      failureOrLoads.fold(
        (_) => emit(
          state.copyWith(isLoading: false, error: 'Ошибка загрузки данных'),
        ),
        (orderData) => emit(
          state.copyWith(error: null, isLoading: false, order: orderData),
        ),
      );
    }
  }

  Future _onRepeatOrderEvent(
      RepeatOrderEvent event, Emitter<OrderScreenState> emit) async {
    emit(state.copyWith(isRepeatingOrder: true));
    final failureOrLoads = await repeatOrderUC(event.orderId);

    failureOrLoads.fold(
      (_) => event.callback(false),
      (isSuccess) => event.callback(isSuccess),
    );
    emit(state.copyWith(isRepeatingOrder: false));
  }
}

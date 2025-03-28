import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/data/models/order_request_model.dart';
import 'package:inlek/features/domain/repositories/order_repository.dart';

class CreateOrderUC extends UseCaseParam<void, OrderRequestModel> {
  final OrderRepository orderRepository;

  CreateOrderUC(this.orderRepository);

  @override
  Future<Either<Failure, void>> call(OrderRequestModel params) async {
    return await orderRepository.createOrder(params);
  }
}

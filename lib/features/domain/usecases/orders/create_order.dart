import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/order_param.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/domain/repositories/order_repository.dart';

class CreateOrderUC extends UseCaseParam<OrderEntity?, OrderParam> {
  final OrderRepository orderRepository;

  CreateOrderUC(this.orderRepository);

  @override
  Future<Either<Failure, OrderEntity?>> call(OrderParam params) async {
    return await orderRepository.createOrder(params);
  }
}

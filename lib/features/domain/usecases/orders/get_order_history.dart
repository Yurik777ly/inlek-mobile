import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/domain/repositories/order_repository.dart';

class GetOrderHistoryUC extends UseCase<List<OrderEntity>> {
  final OrderRepository orderRepository;

  GetOrderHistoryUC(this.orderRepository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call() async {
    return await orderRepository.getOrderHistory();
  }
}

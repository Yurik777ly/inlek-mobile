import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/order_repository.dart';

class RepeatOrderUC extends UseCaseParam<bool, int> {
  final OrderRepository orderRepository;

  RepeatOrderUC(this.orderRepository);

  @override
  Future<Either<Failure, bool>> call(int params) async {
    return await orderRepository.repeatOrder(params);
  }
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';

class DeleteCartUC extends UseCaseParam<void, CartParams> {
  final CartRepository cartRepository;

  DeleteCartUC(this.cartRepository);

  @override
  Future<Either<Failure, void>> call(CartParams params) async {
    return await cartRepository.deleteCart(params);
  }
}

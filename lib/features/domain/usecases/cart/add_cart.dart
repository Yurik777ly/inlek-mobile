import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';

class AddCartUC extends UseCaseParam<void, CartParams> {
  final CartRepository cartRepository;

  AddCartUC(this.cartRepository);

  @override
  Future<Either<Failure, void>> call(CartParams params) async {
    return await cartRepository.addCart(params);
  }
}

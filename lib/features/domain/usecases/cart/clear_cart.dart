import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';

class ClearCartUC extends UseCase<void> {
  final CartRepository cartRepository;

  ClearCartUC(this.cartRepository);

  @override
  Future<Either<Failure, void>> call() async {
    return await cartRepository.clearCart();
  }
}

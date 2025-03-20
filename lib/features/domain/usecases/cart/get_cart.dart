import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';

class GetCartUC extends UseCase<CartEntity> {
  final CartRepository cartRepository;

  GetCartUC(this.cartRepository);

  @override
  Future<Either<Failure, CartEntity>> call() async {
    return await cartRepository.getCart();
  }
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, void>> addCart(CartParams params);
  Future<Either<Failure, void>> deleteCart(CartParams params);
  Future<Either<Failure, void>> clearCart();
  Future<Either<Failure, List<PharmacyEntity>>> getCartPharmacies();
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/cart_detailed_params.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/params/pharmacies_by_cart_params.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/cart_remote_data_source_impl.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource cartRemoteDataSource;
  final NetworkInfo networkInfo;
  final ErrorHandler errorHandler;

  const CartRepositoryImpl({
    required this.cartRemoteDataSource,
    required this.networkInfo,
    required this.errorHandler,
  });

  // 📌 Добавление продуктов в корзину
  @override
  Future<Either<Failure, void>> addCart(CartParams params) async =>
      await errorHandler.handle(
        () async => await cartRemoteDataSource.addCart(params),
      );

  // 📌 Удаление продукта из корзины
  @override
  Future<Either<Failure, void>> deleteCart(CartParams params) async =>
      await errorHandler.handle(
        () async => await cartRemoteDataSource.deleteCart(params),
      );

  // 📌 Получение продуктов корзины
  @override
  Future<Either<Failure, CartEntity>> getCart(
          CartDetailedParams params) async =>
      await errorHandler.handle(
        () async => await cartRemoteDataSource.getCart(params),
      );

  // 📌 Получение продуктов корзины
  @override
  Future<Either<Failure, void>> clearCart() async => await errorHandler.handle(
        () async => await cartRemoteDataSource.clearCart(),
      );

  // 📌 Получение доступных аптек
  @override
  Future<Either<Failure, List<PharmacyEntity>>> getCartPharmacies(
          PharmaciesByCartParams params) async =>
      await errorHandler.handle(
        () async => await cartRemoteDataSource.getCartPharmacies(params),
      );
}

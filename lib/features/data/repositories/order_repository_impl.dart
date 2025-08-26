import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/order_param.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/order_remote_data_source_impl.dart';
import 'package:inlek/features/data/models/order_model.dart';
import 'package:inlek/features/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource orderRemoteDataSource;
  final NetworkInfo networkInfo;
  final ErrorHandler errorHandler;

  const OrderRepositoryImpl({
    required this.orderRemoteDataSource,
    required this.networkInfo,
    required this.errorHandler,
  });

  // 📌 Получение списка заказов
  @override
  Future<Either<Failure, List<OrderModel>>> getOrderHistory() async =>
      await errorHandler.handle(
        () async => await orderRemoteDataSource.getOrderHistory(),
      );

  // 📌 Получение заказа по ID
  @override
  Future<Either<Failure, OrderModel?>> getOrderById(int id) async =>
      await errorHandler.handle(
        () async => await orderRemoteDataSource.getOrderById(id),
      );

  // 📌 Создание заказа
  @override
  Future<Either<Failure, OrderModel?>> createOrder(OrderParam params) async =>
      await errorHandler.handle(
        () async => await orderRemoteDataSource.createOrder(params),
      );

  // 📌 Повторить заказ
  @override
  Future<Either<Failure, bool>> repeatOrder(int id) async =>
      await errorHandler.handle(
        () async => await orderRemoteDataSource.repeatOrder(id),
      );
}

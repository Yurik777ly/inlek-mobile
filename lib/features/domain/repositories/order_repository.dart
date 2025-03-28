import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/features/data/models/order_request_model.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory();
  Future<Either<Failure, OrderEntity?>> getOrderById(int id);
  Future<Either<Failure, void>> createOrder(OrderRequestModel order);
}

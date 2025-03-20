import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/product_remote_data_source_impl.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/product_pharmacy_entity.dart';
import 'package:inlek/features/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource productRemoteDataSource;
  final NetworkInfo networkInfo;
  final ErrorHandler errorHandler;

  const ProductRepositoryImpl({
    required this.productRemoteDataSource,
    required this.networkInfo,
    required this.errorHandler,
  });

  // 📌 Получение списка ежедневных продуктов
  @override
  Future<Either<Failure, List<ProductEntity>>> getDailyProducts() async =>
      await errorHandler.handle(
        () async => await productRemoteDataSource.getDailyProducts(),
      );

  // 📌 Получение продукта по ID
  @override
  Future<Either<Failure, ProductEntity?>> getProductById(int id) async =>
      await errorHandler.handle(
        () async => await productRemoteDataSource.getProductById(id),
      );

  // 📌 Получение списка продуктов по параметрам
  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
          ProductParam param) async =>
      await errorHandler.handle(
        () async => await productRemoteDataSource.searchProducts(param),
      );

  // 📌 Получение списка аптек, где продукт в наличии
  @override
  Future<Either<Failure, List<ProductPharmacyEntity>>> getProductPharmacies(
          int id) async =>
      await errorHandler.handle(
        () async => await productRemoteDataSource.getProductPharmacies(id),
      );
}

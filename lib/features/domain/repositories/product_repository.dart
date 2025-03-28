import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/product_pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/search_products_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getDailyProducts();
  Future<Either<Failure, ProductEntity?>> getProductById(int id);
  Future<Either<Failure, SearchProductsEntity>> searchProducts(
      ProductParam param);
  Future<Either<Failure, List<ProductPharmacyEntity>>> getProductPharmacies(
      int id);
}

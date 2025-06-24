import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/pharmacies_by_product_params.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/search_products_entity.dart';
import 'package:inlek/features/domain/entities/search_products_v2_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getDailyProducts();
  Future<Either<Failure, ProductEntity?>> getProductById(int id);
  Future<Either<Failure, SearchProductsEntity>> searchProducts(
      ProductParam param);
  Future<Either<Failure, SearchProductsV2Entity?>> searchProductV2(
      String query);
  Future<Either<Failure, List<PharmacyEntity>>> getProductPharmacies(
      PharmaciesByProductParams params);
}

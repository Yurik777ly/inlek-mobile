import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/search_products_v2_entity.dart';
import 'package:inlek/features/domain/repositories/product_repository.dart';

class SearchProductsV2UC extends UseCaseParam<SearchProductsV2Entity?, String> {
  final ProductRepository productRepository;

  SearchProductsV2UC(this.productRepository);

  @override
  Future<Either<Failure, SearchProductsV2Entity?>> call(String params) async {
    return await productRepository.searchProductV2(params);
  }
}

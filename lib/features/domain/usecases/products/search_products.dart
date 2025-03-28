import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/search_products_entity.dart';
import 'package:inlek/features/domain/repositories/product_repository.dart';

class SearchProductsUC
    extends UseCaseParam<SearchProductsEntity, ProductParam> {
  final ProductRepository productRepository;

  SearchProductsUC(this.productRepository);

  @override
  Future<Either<Failure, SearchProductsEntity>> call(
      ProductParam params) async {
    return await productRepository.searchProducts(params);
  }
}

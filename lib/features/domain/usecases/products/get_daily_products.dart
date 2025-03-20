import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/repositories/product_repository.dart';

class GetDailyProductsUC extends UseCase<List<ProductEntity>> {
  final ProductRepository productRepository;

  GetDailyProductsUC(this.productRepository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call() async {
    return await productRepository.getDailyProducts();
  }
}

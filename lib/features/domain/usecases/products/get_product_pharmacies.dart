import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/repositories/product_repository.dart';

class GetProductPharmaciesUC extends UseCaseParam<List<PharmacyEntity>, int> {
  final ProductRepository productRepository;

  GetProductPharmaciesUC(this.productRepository);

  @override
  Future<Either<Failure, List<PharmacyEntity>>> call(int params) async {
    return await productRepository.getProductPharmacies(params);
  }
}

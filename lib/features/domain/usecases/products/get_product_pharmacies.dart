import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/pharmacies_by_product_params.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/repositories/product_repository.dart';

class GetProductPharmaciesUC
    extends UseCaseParam<List<PharmacyEntity>, PharmaciesByProductParams> {
  final ProductRepository productRepository;

  GetProductPharmaciesUC(this.productRepository);

  @override
  Future<Either<Failure, List<PharmacyEntity>>> call(
      PharmaciesByProductParams params) async {
    return await productRepository.getProductPharmacies(params);
  }
}

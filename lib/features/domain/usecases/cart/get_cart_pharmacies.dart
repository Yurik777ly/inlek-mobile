import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/pharmacies_by_cart_params.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';

class GetCartPharmaciesUC
    extends UseCaseParam<List<PharmacyEntity>, PharmaciesByCartParams> {
  final CartRepository cartRepository;

  GetCartPharmaciesUC(this.cartRepository);

  @override
  Future<Either<Failure, List<PharmacyEntity>>> call(
      PharmaciesByCartParams params) async {
    return await cartRepository.getCartPharmacies(params);
  }
}

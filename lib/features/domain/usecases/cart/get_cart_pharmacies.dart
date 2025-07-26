import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/cart_pharmacies_param.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/data/models/cart_pharmacies_model.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';

class GetCartPharmaciesUC
    extends UseCaseParam<List<CartPharmacyModel>, CartPharmaciesParam> {
  final CartRepository cartRepository;

  GetCartPharmaciesUC(this.cartRepository);

  @override
  Future<Either<Failure, List<CartPharmacyModel>>> call(
      CartPharmaciesParam param) async {
    return await cartRepository.getCartPharmacies(param);
  }
}

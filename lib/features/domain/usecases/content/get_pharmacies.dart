import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetPharmaciesUC extends UseCaseParam<List<PharmacyEntity>, String> {
  final ContentRepository contentRepository;

  GetPharmaciesUC(this.contentRepository);

  @override
  Future<Either<Failure, List<PharmacyEntity>>> call(String params) async {
    return await contentRepository.getPharmacies(params);
  }
}

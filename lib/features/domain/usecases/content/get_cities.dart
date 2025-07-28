import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/city_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetCitiesUC extends UseCase<List<CityEntity>> {
  final ContentRepository contentRepository;

  GetCitiesUC(this.contentRepository);

  @override
  Future<Either<Failure, List<CityEntity>>> call() async {
    return await contentRepository.getCities();
  }
}

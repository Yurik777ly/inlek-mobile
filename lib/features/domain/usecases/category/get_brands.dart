import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/category_repository.dart';

class GetBrandsUC extends UseCaseParam<List<String>, int> {
  final CategoryRepository categoryRepository;

  GetBrandsUC(this.categoryRepository);

  @override
  Future<Either<Failure, List<String>>> call(int params) async {
    return await categoryRepository.getBrands(params);
  }
}

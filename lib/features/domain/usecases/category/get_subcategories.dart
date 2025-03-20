import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/domain/repositories/category_repository.dart';

class GetSubcategoriesUC extends UseCaseParam<List<CategoryEntity>, int> {
  final CategoryRepository categoryRepository;

  GetSubcategoriesUC(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(int params) async {
    return await categoryRepository.getCategories(id: params);
  }
}

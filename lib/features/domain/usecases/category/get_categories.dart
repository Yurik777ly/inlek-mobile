import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/domain/repositories/category_repository.dart';

class GetCategoriesUC extends UseCase<List<CategoryEntity>> {
  final CategoryRepository categoryRepository;

  GetCategoriesUC(this.categoryRepository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() async {
    return await categoryRepository.getCategories();
  }
}

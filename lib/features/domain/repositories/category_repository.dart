import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({int id});
  Future<Either<Failure, List<String>>> getCountries(int categoryId);
  Future<Either<Failure, List<String>>> getForms(int categoryId);
  Future<Either<Failure, List<String>>> getBrands(int categoryId);
}

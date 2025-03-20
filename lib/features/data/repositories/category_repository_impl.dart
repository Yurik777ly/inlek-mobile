import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/category_remote_data_source_impl.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource categoryRemoteDataSource;
  final NetworkInfo networkInfo;
  final ErrorHandler errorHandler;

  const CategoryRepositoryImpl({
    required this.categoryRemoteDataSource,
    required this.networkInfo,
    required this.errorHandler,
  });

  // 📌 Получение списка категорий/подкатегорий
  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories(
          {int? id}) async =>
      await errorHandler.handle(
        () async => await categoryRemoteDataSource.getCategories(id: id),
      );
  // 📌 Получение списка производителей
  @override
  Future<Either<Failure, List<String>>> getBrands(int categoryId) async =>
      await errorHandler.handle(
        () async => await categoryRemoteDataSource.getBrands(categoryId),
      );

  // 📌 Получение списка стран
  @override
  Future<Either<Failure, List<String>>> getCountries(int categoryId) async =>
      await errorHandler.handle(
        () async => await categoryRemoteDataSource.getCountries(categoryId),
      );

  // 📌 Получение списка форм выпуска
  @override
  Future<Either<Failure, List<String>>> getForms(int categoryId) async =>
      await errorHandler.handle(
        () async => await categoryRemoteDataSource.getForms(categoryId),
      );
}

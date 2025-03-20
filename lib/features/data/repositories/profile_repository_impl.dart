import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/profile_remote_data_source_impl.dart';
import 'package:inlek/features/data/models/profile_model.dart';
import 'package:inlek/features/domain/entities/profile_entity.dart';
import 'package:inlek/features/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;
  final NetworkInfo networkInfo;
  final ErrorHandler errorHandler;

  const ProfileRepositoryImpl({
    required this.profileRemoteDataSource,
    required this.networkInfo,
    required this.errorHandler,
  });

  // 📌 Получения данных профиля
  @override
  Future<Either<Failure, ProfileEntity>> getMe() async =>
      await errorHandler.handle(
        () async => await profileRemoteDataSource.getMe(),
      );

  // 📌 Обновление данных профиля
  @override
  Future<Either<Failure, String?>> updateMe(ProfileModel profile) async =>
      await errorHandler.handle(
        () async => await profileRemoteDataSource.updateMe(profile),
      );

  // 📌 Удаление профиля
  @override
  Future<Either<Failure, void>> deleteMe() async => await errorHandler.handle(
        () async => await profileRemoteDataSource.deleteMe(),
      );
}

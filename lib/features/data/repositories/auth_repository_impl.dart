import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/auth_remote_data_source_impl.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo;
  final ErrorHandler errorHandler;

  const AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.networkInfo,
    required this.errorHandler,
  });

  // 📌 Логин
  @override
  Future<Either<Failure, void>> login(
          String phone, String password, String? fcmToken) async =>
      await errorHandler.handle(
        () async => await authRemoteDataSource.login(phone, password, fcmToken),
      );

  // 📌 Логаут
  @override
  Future<Either<Failure, void>> logout() async => await errorHandler
      .handle(() async => await authRemoteDataSource.logout());

  // 📌 Регистрация
  @override
  Future<Either<Failure, void>> registration(
          String phone, String code, String? fcmToken) async =>
      await errorHandler.handle(
        () async =>
            await authRemoteDataSource.registration(phone, code, fcmToken),
      );

  // 📌 Запрос кода
  @override
  Future<Either<Failure, int>> requestCode(
          String phone, String? fcmToken) async =>
      await errorHandler.handle(
        () async => await authRemoteDataSource.requestCode(phone, fcmToken),
      );

  // 📌 Обновление пароля
  @override
  Future<Either<Failure, void>> updatePassword(
          String phone, String password, String code) async =>
      await errorHandler.handle(
        () async =>
            await authRemoteDataSource.updatePassword(phone, password, code),
      );

  // 📌 Обновление пароля
  @override
  Future<Either<Failure, bool?>> isPhoneExists(String phone) async =>
      await errorHandler.handle(
        () async => await authRemoteDataSource.isPhoneExists(phone),
      );

  // 📌 Обновление FCM токена
  @override
  Future<Either<Failure, void>> updateFCMToken(String fcmToken) async =>
      await errorHandler.handle(
        () async => await authRemoteDataSource.updateFCMToken(fcmToken),
      );
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';

class UpdateFCMTokenUC {
  final AuthRepository repository;

  UpdateFCMTokenUC(this.repository);

  Future<Either<Failure, void>> call(String fcmToken) async {
    return await repository.updateFCMToken(fcmToken);
  }
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';

class LogoutUC extends UseCase<void> {
  final AuthRepository authRepository;

  LogoutUC(this.authRepository);

  @override
  Future<Either<Failure, void>> call() async {
    return await authRepository.logout();
  }
}

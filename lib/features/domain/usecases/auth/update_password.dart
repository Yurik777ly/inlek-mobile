import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/authentification_param.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';

class UpdatePasswordUC extends UseCaseParam<void, AuthenticationParams> {
  final AuthRepository authRepository;

  UpdatePasswordUC(this.authRepository);

  @override
  Future<Either<Failure, void>> call(AuthenticationParams params) async {
    return await authRepository.updatePassword(
        params.phone, params.password!, params.code!);
  }
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/authentification_param.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';

class RegistrationUC extends UseCaseParam<void, AuthenticationParams> {
  final AuthRepository authRepository;

  RegistrationUC(this.authRepository);

  @override
  Future<Either<Failure, void>> call(AuthenticationParams params) async {
    return await authRepository.registration(params.phone, params.code!, params.fbid);
  }
}

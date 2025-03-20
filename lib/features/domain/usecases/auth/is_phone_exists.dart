import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/authentification_param.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';

class IsPhoneExistsUC extends UseCaseParam<void, AuthenticationParams> {
  final AuthRepository authRepository;

  IsPhoneExistsUC(this.authRepository);

  @override
  Future<Either<Failure, bool?>> call(AuthenticationParams params) async {
    return await authRepository.isPhoneExists(params.phone);
  }
}

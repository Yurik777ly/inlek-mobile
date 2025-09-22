import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/authentification_param.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';

class RequestCodeUC extends UseCaseParam<void, AuthenticationParams> {
  final AuthRepository authRepository;

  RequestCodeUC(this.authRepository);

  @override
  Future<Either<Failure, int>> call(AuthenticationParams params) async {
    return await authRepository.requestCode(params.phone, params.fbid);
  }
}

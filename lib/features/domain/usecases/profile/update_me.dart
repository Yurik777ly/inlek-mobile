import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/data/models/profile_model.dart';
import 'package:inlek/features/domain/repositories/profile_repository.dart';

class UpdateMeUC extends UseCaseParam<String?, ProfileModel> {
  final ProfileRepository profileRepository;

  UpdateMeUC(this.profileRepository);

  @override
  Future<Either<Failure, String?>> call(ProfileModel params) async {
    return await profileRepository.updateMe(params);
  }
}

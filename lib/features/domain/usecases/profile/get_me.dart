import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/profile_entity.dart';
import 'package:inlek/features/domain/repositories/profile_repository.dart';

class GetMeUC extends UseCase<ProfileEntity> {
  final ProfileRepository profileRepository;

  GetMeUC(this.profileRepository);

  @override
  Future<Either<Failure, ProfileEntity>> call() async {
    return await profileRepository.getMe();
  }
}

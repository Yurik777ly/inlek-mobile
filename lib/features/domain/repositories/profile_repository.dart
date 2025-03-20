import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/features/data/models/profile_model.dart';
import 'package:inlek/features/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getMe();
  Future<Either<Failure, String?>> updateMe(ProfileModel profile);
  Future<Either<Failure, void>> deleteMe();
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';

abstract class UseCaseParam<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UseCase<Type> {
  Future<Either<Failure, Type>> call();
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetOneActionUC extends UseCaseParam<ActionEntity, int> {
  final ContentRepository contentRepository;

  GetOneActionUC(this.contentRepository);

  @override
  Future<Either<Failure, ActionEntity>> call(int params) async {
    return await contentRepository.getOneAction(params);
  }
}

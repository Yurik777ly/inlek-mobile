import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetActionsUC extends UseCase<List<ActionEntity>> {
  final ContentRepository contentRepository;

  GetActionsUC(this.contentRepository);

  @override
  Future<Either<Failure, List<ActionEntity>>> call() async {
    return await contentRepository.getActions();
  }
}

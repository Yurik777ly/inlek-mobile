import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/news_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetOneNewsUC extends UseCaseParam<NewsEntity, int> {
  final ContentRepository contentRepository;

  GetOneNewsUC(this.contentRepository);

  @override
  Future<Either<Failure, NewsEntity>> call(int params) async {
    return await contentRepository.getOneNews(params);
  }
}

import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/article_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetOneArticleUC extends UseCaseParam<ArticleEntity, int> {
  final ContentRepository contentRepository;

  GetOneArticleUC(this.contentRepository);

  @override
  Future<Either<Failure, ArticleEntity>> call(int params) async {
    return await contentRepository.getOneArticle(params);
  }
}

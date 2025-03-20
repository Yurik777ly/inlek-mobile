import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/article_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetArticlesUC extends UseCase<List<ArticleEntity>> {
  final ContentRepository contentRepository;

  GetArticlesUC(this.contentRepository);

  @override
  Future<Either<Failure, List<ArticleEntity>>> call() async {
    return await contentRepository.getArticles();
  }
}

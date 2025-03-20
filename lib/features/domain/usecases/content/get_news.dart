import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/usecases/usecase.dart';
import 'package:inlek/features/domain/entities/news_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class GetNewsUC extends UseCase<List<NewsEntity>> {
  final ContentRepository contentRepository;

  GetNewsUC(this.contentRepository);

  @override
  Future<Either<Failure, List<NewsEntity>>> call() async {
    return await contentRepository.getNews();
  }
}

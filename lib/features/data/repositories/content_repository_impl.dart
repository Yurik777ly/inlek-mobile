import 'package:dartz/dartz.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/content_remote_data_source_impl.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/domain/entities/article_entity.dart';
import 'package:inlek/features/domain/entities/banner_entity.dart';
import 'package:inlek/features/domain/entities/news_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource contentRemoteDataSource;
  final NetworkInfo networkInfo;
  final ErrorHandler errorHandler;

  const ContentRepositoryImpl({
    required this.contentRemoteDataSource,
    required this.networkInfo,
    required this.errorHandler,
  });

  // 📌 Получение списка действий
  @override
  Future<Either<Failure, List<ActionEntity>>> getActions() async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getActions(),
      );

// 📌 Получение списка статей
  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticles() async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getArticles(),
      );

// 📌 Получение списка баннеров
  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getBanners(),
      );

// 📌 Получение списка новостей
  @override
  Future<Either<Failure, List<NewsEntity>>> getNews() async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getNews(),
      );

// 📌 Получение одного действия по ID
  @override
  Future<Either<Failure, ActionEntity>> getOneAction(int id) async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getOneAction(id),
      );

// 📌 Получение одной статьи по ID
  @override
  Future<Either<Failure, ArticleEntity>> getOneArticle(int id) async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getOneArticle(id),
      );

// 📌 Получение одной новости по ID
  @override
  Future<Either<Failure, NewsEntity>> getOneNews(int id) async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getOneNews(id),
      );

// 📌 Получение списка аптек с фильтром по адресу
  @override
  Future<Either<Failure, List<PharmacyEntity>>> getPharmacies(
          String address) async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getPharmacies(address),
      );

// 📌 Получение списка городов
  @override
  Future<Either<Failure, List<String>>> getCities() async =>
      await errorHandler.handle(
        () async => await contentRemoteDataSource.getCities(),
      );
}

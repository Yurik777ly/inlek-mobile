import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inlek/core/error/exception.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/action_model.dart';
import 'package:inlek/features/data/models/article_model.dart';
import 'package:inlek/features/data/models/banner_model.dart';
import 'package:inlek/features/data/models/city_model.dart';
import 'package:inlek/features/data/models/news_model.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ContentRemoteDataSource {
  Future<List<NewsModel>> getNews();
  Future<NewsModel> getOneNews(int id);
  Future<List<ActionModel>> getActions();
  Future<ActionModel> getOneAction(int id);
  Future<List<ArticleModel>> getArticles();
  Future<ArticleModel> getOneArticle(int id);
  Future<List<BannerModel>> getBanners();
  Future<List<PharmacyModel>> getPharmacies(String address);
  Future<List<CityModel>> getCities();
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  ContentRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<List<ActionModel>> getActions() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final url = '${baseUrl}actions';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final raw = data['data'];

        if (raw == null) {
          return [];
        }

        final dataList = raw is List
            ? raw
            : raw is Map
                ? raw.values.toList()
                : <dynamic>[];

        final actions = <ActionModel>[];

        for (final item in dataList) {
          if (item is! Map) {
            continue;
          }

          try {
            actions.add(
              ActionModel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e, stackTrace) {
            log(
              'Skip invalid action: $e',
              stackTrace: stackTrace,
              level: 1000,
              name: 'ContentRemoteDataSource.getActions',
            );
          }
        }

        return actions;
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getActions: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<List<ArticleModel>> getArticles() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}articles';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> dataList = data['data'];

        return dataList.map((e) => ArticleModel.fromJson(e)).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getArticles: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}banners';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dataMap = data['data'];

        if (dataMap is! Map<String, dynamic>) {
          return [];
        }

        // На главной нужен только слайдер; остальные зоны — aside, catalog и т.д.
        return _parseHomeSliderBanners(dataMap['homeSlider']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getBanners: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<List<NewsModel>> getNews() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}news';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> dataList = data['data'];

        return dataList.map((e) => NewsModel.fromJson(e)).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getNews: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<ActionModel> getOneAction(int id) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}actions/$id';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payload = data['data'];

        if (payload is! Map) {
          throw const FormatException('Invalid action payload');
        }

        final actionMap = Map<String, dynamic>.from(payload);
        final actionJson = actionMap['action'] is Map
            ? Map<String, dynamic>.from(actionMap['action'] as Map)
            : actionMap;

        if (actionMap['products'] != null) {
          actionJson['products'] = actionMap['products'];
        }

        return ActionModel.fromJson(actionJson);
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getOneAction: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<ArticleModel> getOneArticle(int id) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}articles/$id';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return ArticleModel.fromJson(data['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getOneArticle: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<NewsModel> getOneNews(int id) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}news/$id';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return NewsModel.fromJson(data['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getOneNews: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<List<PharmacyModel>> getPharmacies(String address) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}pharmacies?address=$address';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> dataList = data['data'];

        return dataList.map((e) => PharmacyModel.fromJson(e)).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getPharmacies: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<List<CityModel>> getCities() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}cities';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('GET $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      log('Response ( [36m$url [0m): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> dataList = data['data'];

        final cities = <CityModel>[];
        for (final item in dataList) {
          if (item is! Map) {
            continue;
          }

          final map = Map<String, dynamic>.from(item);
          if (map['latitude'] == null || map['longitude'] == null) {
            log('Skip city without coordinates: ${map['alias']}',
                name: 'ContentRemoteDataSource.getCities');
            continue;
          }

          try {
            cities.add(CityModel.fromJson(map));
          } catch (e) {
            log('Skip invalid city ${map['alias']}: $e',
                name: 'ContentRemoteDataSource.getCities');
          }
        }

        return cities;
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getCities: $e', level: 1000);
      rethrow;
    }
  }

  List<BannerModel> _parseHomeSliderBanners(dynamic homeSlider) {
    if (homeSlider is! Map<String, dynamic>) {
      return [];
    }

    final banners = <BannerModel>[];

    for (final entry in homeSlider.values) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final items = entry['items'];
      if (items is! Map<String, dynamic>) {
        continue;
      }

      final image = _readBannerItemValue(items, 'image_mobile');
      if (image == null || image.isEmpty) {
        continue;
      }

      banners.add(
        BannerModel(
          image: image,
          href: _readBannerItemValue(items, 'href'),
        ),
      );
    }

    return banners;
  }

  String? _readBannerItemValue(Map<String, dynamic> items, String key) {
    final field = items[key];
    if (field is! Map<String, dynamic>) {
      return null;
    }

    final value = field['value'];
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }
}

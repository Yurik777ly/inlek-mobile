import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inlek/core/error/exception.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/data/models/search_products_model.dart';
import 'package:inlek/features/data/models/search_products_v2_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getDailyProducts();
  Future<ProductModel?> getProductById(int id);
  Future<SearchProductsModel> searchProducts(ProductParam param);
  Future<SearchProductsV2Model?> searchProductsV2(String query);
  Future<List<PharmacyModel>> getProductPharmacies(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  ProductRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<List<ProductModel>> getDailyProducts() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}product/daily');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('GET Request: $uri', name: 'ProductRemoteDataSource.getDailyProducts');
    log('Headers: $headers', name: 'ProductRemoteDataSource.getDailyProducts');

    try {
      final response = await client.get(uri, headers: headers);

      log('Response Status Code: ${response.statusCode}',
          name: 'ProductRemoteDataSource.getDailyProducts');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> dataList = data['data'];

        return dataList.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getDailyProducts: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}product/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('GET Request: $uri', name: 'ProductRemoteDataSource.getProductById');
    log('Headers: $headers', name: 'ProductRemoteDataSource.getProductById');

    try {
      final response = await client.get(uri, headers: headers);

      log('Response Status Code: ${response.statusCode}',
          name: 'ProductRemoteDataSource.getProductById');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          return ProductModel.fromJson(data['data']);
        }
        return null;
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getProductById: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<SearchProductsModel> searchProducts(ProductParam param) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}product/search').replace(
      queryParameters: param.toJson().map((key, value) {
        if (value is List) {
          return MapEntry('$key[]', value.map((e) => e.toString()).toList());
        }
        return MapEntry(key, value?.toString());
      }),
    );

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('GET Request: $uri', name: 'ProductRemoteDataSource.searchProducts');
    log('Headers: $headers', name: 'ProductRemoteDataSource.searchProducts');

    try {
      final response = await client.get(uri, headers: headers);

      log('Response Status Code: ${response.statusCode}',
          name: 'ProductRemoteDataSource.searchProducts');

      log('Response ($uri): ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        return SearchProductsModel.fromJson(data);
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during searchProducts: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<List<PharmacyModel>> getProductPharmacies(int id) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}product/$id/pharmacies');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('GET Request: $uri',
        name: 'ProductRemoteDataSource.getProductPharmacies');
    log('Headers: $headers',
        name: 'ProductRemoteDataSource.getProductPharmacies');

    try {
      final response = await client.get(uri, headers: headers);

      log('Response Status Code: ${response.statusCode}',
          name: 'ProductRemoteDataSource.getProductPharmacies');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> dataList = data['data'];

        return dataList
            .map((e) => PharmacyModel.fromJson(e['product_pharmacy_json']))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during getProductPharmacies: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<SearchProductsV2Model?> searchProductsV2(String query) async {
    //String baseUrl = "${dotenv.env['PUBLIC_URL']}api/v1/";

    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    //final uri = Uri.parse('${baseUrl}search?search=$query');
    final uri = Uri.parse(
        'https://api.rees46.ru/search?shop_id=a46b953ef509cadb85a3692a13dfac&did=KwkHbFxeho&sid=ptXCvgYD4F&type=instant_search&search_query=$query&collapse=true');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('GET Request: $uri', name: 'ProductRemoteDataSource.searchProductsV2');
    log('Headers: $headers', name: 'ProductRemoteDataSource.searchProductsV2');

    try {
      final response = await client.get(uri, headers: headers);

      log('Response Status Code: ${response.statusCode}',
          name: 'ProductRemoteDataSource.searchProductsV2');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        /*if (data['data'] is List) {
          return null;
        } else if (data['data'] is Map<String, dynamic>) {
          Map<String, dynamic> dataMap = data['data'];

          return SearchProductsV2Model.fromJson(dataMap);
        }*/
        return SearchProductsV2Model.fromJson(data);
        //return null;
      } else {
        throw ServerException();
      }
    } catch (e) {
      log('Error during searchProductsV2: $e', level: 1000);
      rethrow;
    }
  }
}

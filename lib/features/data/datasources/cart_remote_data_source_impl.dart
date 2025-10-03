import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inlek/constants/enums.dart';
import 'package:inlek/core/error/exception.dart';
import 'package:inlek/core/params/cart_detailed_params.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/params/cart_pharmacies_param.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/cart_model.dart';
import 'package:inlek/features/data/models/cart_pharmacies_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart(CartDetailedParams params);
  Future<void> addCart(CartParams params);
  Future<void> deleteCart(CartParams params);
  Future<void> clearCart();
  Future<List<CartPharmacyModel>> getCartPharmacies(CartPharmaciesParam param);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  CartRemoteDataSourceImpl(
      {required this.client, required this.sharedPreferences});

  @override
  Future<CartModel> getCart(CartDetailedParams params) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    // Формируем query-параметры динамически
    final Map<String, String> queryParameters = {};
    if (params.deliveryZone != DeliveryZoneType.none) {
      queryParameters['delivery_zone'] = params.deliveryZone.name;
    }
    if (params.pharmacyId != null) {
      queryParameters['pharmacy_id'] = params.pharmacyId.toString();
    }
    if (params.promocodes.isNotEmpty) {
      queryParameters['promocodes'] = params.promocodes;
    }

    final uri = Uri.parse('${baseUrl}cart/detailed')
        .replace(queryParameters: queryParameters);

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('GET Request: $uri', name: 'CartRemoteDataSourceImpl.getCart');
    log('Headers: $headers', name: 'CartRemoteDataSourceImpl.getCart');

    try {
      final response = await client.get(uri, headers: headers);

      log('Response Status Code: ${response.statusCode}',
          name: 'CartRemoteDataSourceImpl.getCart');
      log('Response Body: ${response.body}',
          name: 'CartRemoteDataSourceImpl.getCart');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data != null) {
          return CartModel.fromJson(data);
        } else {
          return CartModel();
        }
      } else {
        log('Error: ServerException occurred',
            name: 'CartRemoteDataSourceImpl.getCart', error: response.body);
        throw ServerException();
      }
    } catch (e) {
      log('Error during getCart: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<void> addCart(CartParams params) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}cart/add');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };
    final body = jsonEncode(
        {'product_id': params.productId, 'quantity': params.quantity});

    log('PUT Request: $uri', name: 'CartRemoteDataSourceImpl.addCart');
    log('Headers: $headers', name: 'CartRemoteDataSourceImpl.addCart');
    log('Request Body: $body', name: 'CartRemoteDataSourceImpl.addCart');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      log('Response Status Code: ${response.statusCode}',
          name: 'CartRemoteDataSourceImpl.addCart');
      log('Response Body: ${response.body}',
          name: 'CartRemoteDataSourceImpl.addCart');

      switch (response.statusCode) {
        case 200:
          break;
        case 422:
          throw OutOfStockException();

        default:
          throw ServerException();
      }

      if (response.statusCode != 200) {
        throw ServerException();
      }
    } catch (e) {
      log('Error during addCart: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<void> deleteCart(CartParams params) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}cart/add');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };
    final body = jsonEncode(
        {'product_id': params.productId, 'quantity': params.quantity});

    log('PUT Request: $uri', name: 'CartRemoteDataSourceImpl.deleteCart');
    log('Headers: $headers', name: 'CartRemoteDataSourceImpl.deleteCart');
    log('Request Body: $body', name: 'CartRemoteDataSourceImpl.deleteCart');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      log('Response Status Code: ${response.statusCode}',
          name: 'CartRemoteDataSourceImpl.deleteCart');
      log('Response Body: ${response.body}',
          name: 'CartRemoteDataSourceImpl.deleteCart');

      if (response.statusCode != 200) {
        throw ServerException();
      }
    } catch (e) {
      log('Error during deleteCart: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}cart');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('PUT Request: $uri', name: 'CartRemoteDataSourceImpl.clearCart');
    log('Headers: $headers', name: 'CartRemoteDataSourceImpl.clearCart');

    try {
      final response = await client.delete(uri, headers: headers);

      log('Response Status Code: ${response.statusCode}',
          name: 'CartRemoteDataSourceImpl.clearCart');
      log('Response Body: ${response.body}',
          name: 'CartRemoteDataSourceImpl.clearCart');

      if (response.statusCode != 200) {
        throw ServerException();
      }
    } catch (e) {
      log('Error during clearCart: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<List<CartPharmacyModel>> getCartPharmacies(
      CartPharmaciesParam param) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}v2/cart/pharmacies');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $serverToken'
    };

    log('POST Request: $uri',
        name: 'CartRemoteDataSourceImpl.getCartPharmacies');
    log('Headers: $headers',
        name: 'CartRemoteDataSourceImpl.getCartPharmacies');
    log('Body: ${param.toJson()}',
        name: 'CartRemoteDataSourceImpl.getCartPharmacies');

    try {
      final response = await client.post(uri,
          headers: headers, body: json.encode(param.toJson()));

      log('Response Status Code: ${response.statusCode}',
          name: 'CartRemoteDataSourceImpl.getCartPharmacies');
      log('Response Body: ${response.body}',
          name: 'CartRemoteDataSourceImpl.getCartPharmacies');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> pharmaciesJson = data['data'];
        return pharmaciesJson
            .map((e) => CartPharmacyModel.fromJson(e))
            .toList();
      } else {
        log('Error: ServerException occurred',
            name: 'CartRemoteDataSourceImpl.getCartPharmacies',
            error: response.body);
        throw ServerException();
      }
    } catch (e) {
      log('Error during getCartPharmacies: $e', level: 1000);
      rethrow;
    }
  }
}

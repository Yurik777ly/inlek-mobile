import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inlek/core/error/exception.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<void> addCart(CartParams params);
  Future<void> deleteCart(CartParams params);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  CartRemoteDataSourceImpl(
      {required this.client, required this.sharedPreferences});

  @override
  Future<CartModel> getCart() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    final uri = Uri.parse('${baseUrl}cart');
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
        final person = json.decode(response.body)['data'];
        return CartModel.fromJson(person);
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
}

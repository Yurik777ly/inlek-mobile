import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inlek/core/error/exception.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRemoteDataSource {
  Future<bool?> isPhoneExists(String phone);
  Future<int> requestCode(String phone, String? fcmToken);
  Future<void> registration(String phone, String code, String? fcmToken);
  Future<void> updatePassword(String phone, String password, String code);
  Future<void> login(String phone, String password, String? fcmToken);
  Future<void> logout();
  Future<void> updateFCMToken(String fcmToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<void> login(String phone, String password, String? fcmToken) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}auth/login';

    log('POST $url');
    log('Request body: ${jsonEncode({
          'phone': phone,
          'password': password,
          'fcm_token': fcmToken
        })}');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(
            {'phone': phone, 'password': password, 'fcm_token': fcmToken}),
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          bool a = await sharedPreferences.setString(
              SharedPreferencesKeys.accessToken, data['data']['access_token']);
          print(a);

          break;
        case 422:
          final data = json.decode(response.body);
          final errors = data?['data']?['errors'];
          log('Validation errors: $errors');
          if (errors != null) {
            if (errors['phone'] != null) {
              throw PhoneDontFoundException();
            } else if (errors['password'] != null) {
              throw UncorrectedPasswordException();
            }
          }
          throw ServerException();
        default:
          throw ServerException();
      }
    } catch (e) {
      log('Error during login: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}auth/logout';

    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('POST $url');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );
      // очищаем токен
      sharedPreferences.remove(SharedPreferencesKeys.accessToken);
      sharedPreferences.remove(SharedPreferencesKeys.email);
      sharedPreferences.remove(SharedPreferencesKeys.phone);
      sharedPreferences.remove(SharedPreferencesKeys.fullName);
      sharedPreferences.remove(SharedPreferencesKeys.userId);

      log('Response ($url): ${response.statusCode} ${response.body}');

      if (response.statusCode != 200) {
        throw ServerException();
      }
    } catch (e) {
      log('Error during logout: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<void> registration(String phone, String code, String? fcmToken) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}auth/registration';

    log('POST $url');
    log('Request body: ${jsonEncode({
          'phone': phone,
          'code': code,
          'fcm_token': fcmToken,
        })}');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'code': code,
          if (fcmToken != null) 'fcm_token': fcmToken,
        }),
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      switch (response.statusCode) {
        case 200:
          break;
        case 409:
          throw PhoneDontFoundException();
        case 422:
          throw PhoneAlreadyTakenException();
        default:
          throw ServerException();
      }
    } catch (e) {
      log('Error during registration: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<int> requestCode(String phone, String? fcmToken) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}auth/request-code';

    log('POST $url');
    log('Request body: ${jsonEncode({'phone': phone, 'fcm_token': fcmToken})}');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          if (fcmToken != null) 'fcm_token': fcmToken,
        }),
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body) as Map<String, dynamic>;
          final responseData = data['data'];
          if (responseData is Map<String, dynamic>) {
            final code = responseData['code'];
            if (code is int) {
              return code;
            }
            if (code != null) {
              return int.tryParse(code.toString()) ?? 0;
            }
          }
          return 0;
        case 409:
          throw SendingCodeTooOftenException();
        case 422:
          throw InvalidFormatException();
        default:
          throw ServerException();
      }
    } catch (e) {
      log('Error during requestCode: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(
      String phone, String password, String code) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}auth/update-password';

    log('POST $url');
    log('Request body: ${jsonEncode({
          'phone': phone,
          'password': password,
          'code': code
        })}');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password, 'code': code}),
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      switch (response.statusCode) {
        case 200:
          break;

        case 409:
          final data = json.decode(response.body);
          final error = data['data']['error'];
          log('Error 409: $error');
          if (error == 'Код не совпал') {
            throw ConfirmationCodeWrongException();
          }
          throw SessionExpiredException();
        case 422:
          final data = json.decode(response.body);
          final errors = data['errors'];
          log('updatePassword errors: $errors');
          if (errors != null) {
            if (errors['phone'] != null) {
              throw PhoneDontFoundException();
            } else if (errors['password'] != null) {
              throw PasswordMatchesPreviousOneException();
            }
          }
          throw ServerException();

        default:
          throw ServerException();
      }
    } catch (e) {
      log('Error during updatePassword: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<bool?> isPhoneExists(String phone) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}auth/check';

    log('POST $url');
    log('Request body: ${jsonEncode({'phone': phone})}');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          return data['data']['phone'] == 'found';
        case 422:
          throw InvalidFormatException();
        default:
          throw ServerException();
      }
    } catch (e) {
      log('Error during isPhoneExists: $e', level: 1000);
      rethrow;
    }
  }

  @override
  Future<void> updateFCMToken(String fcmToken) async {
    String baseUrl = dotenv.env['BASE_URL']!;
    String url = '${baseUrl}auth/update-fcm-token';
    final String? serverToken =
        sharedPreferences.getString(SharedPreferencesKeys.accessToken);

    log('POST $url');
    log('Request body: ${jsonEncode({'fcm_token': fcmToken})}');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $serverToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );

      log('Response ($url): ${response.statusCode} ${response.body}');

      switch (response.statusCode) {
        case 200:
          log('FCM token updated successfully');
          break;
        case 422:
          throw InvalidFormatException();
        default:
          throw ServerException();
      }
    } catch (e) {
      log('Error during updateFCMToken: $e', level: 1000);
      rethrow;
    }
  }
}

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/usecases/auth/update_fcm_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Менеджер для управления FCM токенами
class FCMTokenManager {
  static FCMTokenManager? _instance;
  static FCMTokenManager get instance => _instance ??= FCMTokenManager._();

  FCMTokenManager._();

  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _currentToken;
  String? _lastSentToken;
  Function(String)? _onTokenUpdate;
  UpdateFCMTokenUC? _updateFCMTokenUC;

  /// Инициализация менеджера токенов
  Future<void> initialize({
    Function(String)? onTokenUpdate,
    UpdateFCMTokenUC? updateFCMTokenUC,
  }) async {
    _onTokenUpdate = onTokenUpdate;
    _updateFCMTokenUC = updateFCMTokenUC;

    // Получаем текущий токен
    await _getCurrentToken();

    // Подписываемся на обновления токена
    _tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen(
      _onTokenRefresh,
      onError: (error) {
        debugPrint('FCM Token refresh error: $error');
      },
    );

    debugPrint('FCMTokenManager initialized with token: $_currentToken');
  }

  /// Получение текущего токена
  Future<String?> _getCurrentToken() async {
    try {
      // На iOS нужно сначала получить APNS токен
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('⚠️ APNS token not available yet, waiting...');
          // Ждем немного и пробуем снова
          await Future.delayed(const Duration(seconds: 1));
          final retryApnsToken =
              await FirebaseMessaging.instance.getAPNSToken();
          if (retryApnsToken == null) {
            debugPrint(
                '⚠️ APNS token still not available, FCM token may be null');
          }
        } else {
          debugPrint('✅ APNS token available: $apnsToken');
        }
      }

      _currentToken = await FirebaseMessaging.instance.getToken();
      debugPrint('Current FCM Token: $_currentToken');
      if (_currentToken != null) {
        await _saveTokenToStorage(_currentToken!);
        await _syncTokenWithServerIfAuthenticated(_currentToken!);
      }
      return _currentToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Обработка обновления токена
  Future<void> _onTokenRefresh(String newToken) async {
    debugPrint('🔄 FCM Token refreshed: $newToken');
    debugPrint('Previous token: $_currentToken');

    _currentToken = newToken;

    // Сохраняем новый токен в SharedPreferences
    await _saveTokenToStorage(newToken);

    // Отправляем новый токен на сервер
    await _sendTokenToServer(newToken);

    // Уведомляем подписчиков
    _onTokenUpdate?.call(newToken);
  }

  /// Сохранение токена в локальное хранилище
  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPreferencesKeys.fcmToken, token);
      debugPrint('FCM Token saved to storage');
    } catch (e) {
      debugPrint('Error saving FCM token to storage: $e');
    }
  }

  /// Отправка токена на сервер, если пользователь авторизован
  Future<void> _syncTokenWithServerIfAuthenticated(String token) async {
    if (_lastSentToken == token) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(SharedPreferencesKeys.accessToken);
      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      await _sendTokenToServer(token);
    } catch (e) {
      debugPrint('Error syncing FCM token with server: $e');
    }
  }

  /// Отправка токена на сервер
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Проверяем, не отправляли ли мы уже этот токен
      if (_lastSentToken == token) {
        debugPrint('Token already sent to server, skipping...');
        return;
      }

      debugPrint('📤 Sending FCM token to server: $token');

      // Отправляем токен на сервер через use case
      if (_updateFCMTokenUC != null) {
        final result = await _updateFCMTokenUC!(token);
        result.fold(
          (failure) {
            debugPrint('❌ Error sending FCM token to server: $failure');
          },
          (_) {
            _lastSentToken = token;
            debugPrint('✅ FCM token sent to server successfully');
          },
        );
      } else {
        debugPrint(
            '⚠️ UpdateFCMTokenUC not initialized, skipping server update');
        _lastSentToken = token;
      }
    } catch (e) {
      debugPrint('❌ Error sending FCM token to server: $e');
    }
  }

  /// Получение актуального токена с ожиданием APNS (для iOS)
  Future<String?> getCurrentToken({bool waitForApns = false}) async {
    // Если токен не получен, получаем его
    if (_currentToken == null) {
      await _getCurrentToken();
    }

    // Если на iOS и токен все еще null, и нужно ждать APNS
    if (Platform.isIOS && _currentToken == null && waitForApns) {
      debugPrint('⏳ Waiting for APNS token...');
      // Пробуем получить токен несколько раз с задержкой
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _getCurrentToken();
        if (_currentToken != null) {
          break;
        }
      }
    }

    return _currentToken;
  }

  /// Принудительное обновление токена
  Future<String?> refreshToken() async {
    try {
      // Удаляем старый токен, чтобы принудительно получить новый
      await FirebaseMessaging.instance.deleteToken();
      _currentToken = null;
      _lastSentToken = null;

      // Получаем новый токен
      return await _getCurrentToken();
    } catch (e) {
      debugPrint('Error refreshing FCM token: $e');
      return null;
    }
  }

  /// Проверка, нужно ли обновить токен на сервере
  bool needsServerUpdate() {
    return _currentToken != null && _currentToken != _lastSentToken;
  }

  /// Принудительная отправка токена на сервер
  Future<void> forceSendToServer() async {
    if (_currentToken != null) {
      await _sendTokenToServer(_currentToken!);
    }
  }

  /// Очистка ресурсов
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _currentToken = null;
    _lastSentToken = null;
    _onTokenUpdate = null;
  }
}

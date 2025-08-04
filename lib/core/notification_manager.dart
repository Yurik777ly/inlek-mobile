import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/firebase_options.dart';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static late AndroidNotificationChannel channel;
  static bool isFlutterLocalNotificationsInitialized = false;

  static StreamSubscription<RemoteMessage>? _messageSubscription;
  static Function(String?)? _onNotificationClick;

  static Future<void> initNotifications(
      {Function(String?)? handleNotificationClick}) async {
    _onNotificationClick = handleNotificationClick;
    _requestNotificationPermissions();
    if (isFlutterLocalNotificationsInitialized) return;

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    isFlutterLocalNotificationsInitialized = true;

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('onDidReceiveNotificationResponse');
        debugPrint('onDidReceiveNotificationResponse: ${response.payload}');
        _onNotificationClick?.call(response.payload);
      },
    );

    // Подписка на onMessageOpenedApp только здесь
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp');
      print('onMessageOpenedApp: ${message.data}');
      _onNotificationClick?.call(json.encode(message.data));
    });
  }

  static Future<void> connectToForegroundMessages() async {
    _messageSubscription ??=
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      if (!Platform.isIOS) {
        showFlutterNotification(message);
      }
    });
  }

  static Future<void> disconnectFromForegroundMessages() async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  static Future<void> showFlutterNotification(
      RemoteMessage remoteMessage) async {
    const androidDetails = AndroidNotificationDetails(
        'high_importance_channel', 'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: 'ic_notification',
        color: UiConstants.pink2Color,
        ongoing: true,
        setAsGroupSummary: true);

    const iOSDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      remoteMessage.hashCode,
      remoteMessage.data['title'] ?? remoteMessage.notification?.title ?? '',
      remoteMessage.data['body'] ?? remoteMessage.notification?.body ?? '',
      platformDetails,
      payload: json.encode(remoteMessage.data),
    );
  }

  static Future<void> _requestNotificationPermissions() async {
    final messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Уведомления разрешены');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('Уведомления разрешены временно (provisional)');
    } else {
      debugPrint('Уведомления не разрешены');
    }
  }

  static Future<void> handleInitialMessage(
      {Function(String?)? onInitialMessage}) async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    debugPrint('handleInitialMessage');
    debugPrint('handleInitialMessage: ${initialMessage?.data}');
    if (initialMessage != null) {
      onInitialMessage?.call(json.encode(initialMessage.data));
    }
  }

  static Future<void> setupAllPushHandlers(
      {Function(String?)? onPushNavigate}) async {
    _onNotificationClick = onPushNavigate;
    await initNotifications(handleNotificationClick: _onNotificationClick);
    await connectToForegroundMessages();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await handleInitialMessage(onInitialMessage: _onNotificationClick);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('_firebaseMessagingBackgroundHandler');
  debugPrint('_firebaseMessagingBackgroundHandler: ${message.data}');
  //await NotificationManager.showFlutterNotification(message);
}

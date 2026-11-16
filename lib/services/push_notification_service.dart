import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/firebase_options.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  debugPrint('[FCM Background] Notificación recibida: ${message.messageId} | ${message.notification?.title}');
}

class PushNotificationService {
  static const String topicPaquetes = 'paquetes_sorpresa';

  // Lazy so the service can be created even when Firebase failed to start;
  // local notifications do not depend on it.
  late final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'paquetes_sorpresa_channel',
    'Packs Sorpresa ODS 12',
    description: 'Alertas de nuevos packs sorpresa disponibles para rescatar',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel _pedidosChannel =
      AndroidNotificationChannel(
        'pedidos_channel',
        'Pedidos',
        description: 'Avisos de nuevos pedidos para el personal',
        importance: Importance.high,
        playSound: true,
      );

  Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Estado de permisos: ${settings.authorizationStatus}');

      await _setupLocalNotifications();

      await _fcm.subscribeToTopic(topicPaquetes);
      debugPrint('[FCM] Suscrito exitosamente al topic "$topicPaquetes"');

      // Escuchar notificaciones cuando la app está en primer plano (Foreground)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Escuchar cuando el usuario toca la notificación con la app en segundo plano
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] Notificación abierta desde segundo plano');
        _processNotificationData(message.data);
      });

      // Manejar apertura de notificación cuando la app estaba completamente cerrada (Terminated)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] App abierta desde estado cerrado por notificación');
        Future.delayed(const Duration(milliseconds: 500), () {
          _processNotificationData(initialMessage.data);
        });
      }
    } catch (e, stack) {
      debugPrint('[FCM] Error inicializando PushNotificationService: $e\n$stack');
    }
  }

  Future<void> _setupLocalNotifications() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
      await androidPlugin.createNotificationChannel(_pedidosChannel);
      await androidPlugin.requestNotificationsPermission();
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _processNotificationData(data);
          } catch (e) {
            debugPrint('[FCM] Error decodificando payload local: $e');
          }
        }
      },
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM Foreground] Mensaje recibido: ${message.notification?.title}');
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Shows a new-order alert for staff; tapping it opens the kitchen screen.
  Future<void> showOrderNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _localNotifications.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _pedidosChannel.id,
            _pedidosChannel.name,
            channelDescription: _pedidosChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(const {'route': '/cocina', 'tab': ''}),
      );
    } catch (e) {
      debugPrint('[Notificaciones] Error mostrando aviso de pedido: $e');
    }
  }

  void _processNotificationData(Map<String, dynamic> data) {
    debugPrint('[FCM] Procesando payload: $data');
    final tab = data['tab']?.toString() ?? 'paquetes';
    final route = data['route']?.toString() ?? '/cliente/pedidos';

    try {
      final target = tab.isEmpty ? route : '$route?tab=$tab';
      debugPrint('[FCM] Redirigiendo a: $target');
      if (getIt.isRegistered<GoRouter>()) {
        getIt<GoRouter>().go(target);
      }
    } catch (e) {
      debugPrint('[FCM] Error navegando a ruta de notificación: $e');
    }
  }
}

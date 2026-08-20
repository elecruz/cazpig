import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Manejador para mensajes recibidos en background o app cerrada
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Notificación en background recibida: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Manejo en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Solicitar permisos de notificación en el dispositivo
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permisos de notificaciones concedidos.');
    }

    // 3. Listener en primer plano (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notificación en primer plano: ${message.notification?.title}');
    });
  }

  // Activar o desactivar suscripciones a los temas de recordatorios
  static Future<void> toggleNotifications(bool enabled) async {
    if (enabled) {
      await _fcm.subscribeToTopic('daily_reminders');
      debugPrint('Suscrito exitosamente a los recordatorios diarios.');
    } else {
      await _fcm.unsubscribeFromTopic('daily_reminders');
      debugPrint('Desuscrito de los recordatorios diarios.');
    }
  }
}
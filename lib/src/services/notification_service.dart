import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Manejador para mensajes recibidos en background o app cerrada
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Notificación en background recibida: ${message.messageId}");
}

class NotificationService {
  static FirebaseMessaging? get _fcm => Firebase.apps.isNotEmpty ? FirebaseMessaging.instance : null;

  static Future<void> initialize() async {
    if (_fcm == null) return;
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Permisos de notificaciones concedidos.');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Notificación en primer plano: ${message.notification?.title}');
      });
    } catch (e) {
      debugPrint('No se pudo inicializar las notificaciones de Firebase: $e');
    }
  }

  // Activar o desactivar suscripciones a los temas de recordatorios
  static Future<void> toggleNotifications(bool enabled) async {
    if (_fcm == null) return;
    try {
      if (enabled) {
        await _fcm!.subscribeToTopic('daily_reminders');
        debugPrint('Suscrito exitosamente a los recordatorios diarios.');
      } else {
        await _fcm!.unsubscribeFromTopic('daily_reminders');
        debugPrint('Desuscrito de los recordatorios diarios.');
      }
    } catch (e) {
      debugPrint('Error al cambiar notificaciones: $e');
    }
  }
}
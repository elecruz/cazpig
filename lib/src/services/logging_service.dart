import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class LoggingService {
  // Instancias defensivas de los servicios de Firebase
  static FirebaseCrashlytics? get _crashlytics => Firebase.apps.isNotEmpty && !kIsWeb ? FirebaseCrashlytics.instance : null;
  static FirebaseAnalytics? get _analytics => Firebase.apps.isNotEmpty ? FirebaseAnalytics.instance : null;

  /// Inicialización global del servicio de monitoreo en el arranque de la app
  static Future<void> inicializar() async {
    if (kIsWeb || Firebase.apps.isEmpty) {
      print('ℹ️ [MONITOREO] Entorno Web o sin Firebase detectado. Omitido.');
      return;
    }

    try {
      if (kDebugMode) {
        await _crashlytics?.setCrashlyticsCollectionEnabled(false);
        print('ℹ️ [MONITOREO] Crashlytics desactivado en modo Desarrollo (Móvil).');
      } else {
        await _crashlytics?.setCrashlyticsCollectionEnabled(true);
        if (_crashlytics != null) {
          FlutterError.onError = _crashlytics!.recordFlutterFatalError;
        }
      }
    } catch (e) {
      print('⚠️ [MONITOREO] No se pudo inicializar Crashlytics: $e');
    }
  }

  /// Registra un evento de seguridad estructurado (OWASP A09)
  static Future<void> logSecurityEvent({
    required String nombreEvento,
    required String descripcion,
    Map<String, Object>? detalles,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'security_$nombreEvento',
        parameters: detalles ?? {},
      );

      if (!kIsWeb) {
        await _crashlytics?.log('ALERTA SEGURO [${nombreEvento.toUpperCase()}]: $descripcion');
      }
    } catch (_) {}

    if (kDebugMode) {
      print('⚠️ [LOG DE SEGURIDAD] $nombreEvento: $descripcion');
    }
  }

  /// Registra excepciones o fallos técnicos controlados dentro de bloques try-catch
  static Future<void> logException(
    dynamic exception, 
    StackTrace stack, {
    String reason = '',
  }) async {
    if (kIsWeb || Firebase.apps.isEmpty) {
      print('❌ [EXCEPCIÓN LOCAL] Razón: $reason | Error: $exception\n$stack');
      return;
    }

    try {
      await _crashlytics?.recordError(exception, stack, reason: reason);
    } catch (_) {}

    if (kDebugMode) {
      print('❌ [EXCEPCIÓN MÓVIL CAPTURADA] Razón: $reason | Error: $exception');
    }
  }
}
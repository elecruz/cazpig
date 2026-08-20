import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/views/screens/splash_screen.dart';
import 'src/services/notification_service.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización defensiva de Firebase y persistencia local para soporte Offline
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 4));

    // Activar persistencia sin conexión de Firestore
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint("Configuración de caché Firestore omitida: $e");
    }

    // Inicializar FCM solo si Firebase encendió correctamente
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint("Notificaciones no soportadas en este entorno: $e");
    }
  } catch (e) {
    debugPrint("Firebase omitido o no compatible en esta plataforma: $e");
  }

  runApp(const CazadoresApp());
}

class CazadoresApp extends StatelessWidget {
  const CazadoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cazadores de Pigmentos',
      home: SplashScreen(), 
    );
  }
}
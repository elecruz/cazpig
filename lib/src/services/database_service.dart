import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../services/logging_service.dart';

class DatabaseService {
  // Getter seguro: solo evalúa Firestore si Firebase fue inicializado correctamente
  FirebaseFirestore? get _db {
    if (Firebase.apps.isNotEmpty) {
      return FirebaseFirestore.instance;
    }
    return null;
  }

  // Convierte TU UserModel a un Map compatible con Firestore
  Map<String, dynamic> _userToMap(UserModel user) {
    return {
      'email': user.email,
      'age': user.age,
      'name': user.name,
      'avatarUrl': user.avatarUrl,
      'xp': user.xp,
      'level': user.level,
      'currentLevelReached': user.currentLevelReached,
      'lives': user.lives,
      'streak': user.streak,
      'pigments': user.pigments,
      'isOffline': user.isOffline,
      'title': user.title,
      'badges': user.badges,
      'lastLogin': FieldValue.serverTimestamp(),
    };
  }

  // Convierte lo que viene de Firestore de vuelta a TU UserModel
  UserModel _mapToUser(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      age: map['age'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      currentLevelReached: map['currentLevelReached'] ?? 1,
      lives: map['lives'] ?? 5,
      streak: map['streak'] ?? 0,
      pigments: map['pigments'] ?? 0,
      isOffline: map['isOffline'] ?? false,
      title: map['title'] ?? '',
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  // 1. Guardar o actualizar el perfil principal del usuario
  Future<void> saveUserProfile(String uid, UserModel user) async {
    try {
      if (_db == null) return;
      await _db!.collection('users').doc(uid).set(_userToMap(user), SetOptions(merge: true));
      print("¡Perfil de usuario sincronizado en Firestore!");
    } catch (e, stack) {
      await LoggingService.logException(e, stack, reason: 'Fallo al sincronizar perfil uid: $uid');
    }
  }

  // 2. Obtener los datos del usuario desde Firestore (con fallback a caché local en offline)
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      if (_db == null) return null;
      DocumentSnapshot doc;
      try {
        doc = await _db!.collection('users').doc(uid).get().timeout(const Duration(seconds: 3));
      } catch (_) {
        doc = await _db!.collection('users').doc(uid).get(const GetOptions(source: Source.cache));
      }

      if (doc.exists && doc.data() != null) {
        return _mapToUser(doc.data() as Map<String, dynamic>);
      }
    } catch (e, stack) {
      await LoggingService.logException(e, stack, reason: 'Error al obtener perfil uid: $uid');
    }
    return null;
  }

  // 3. Guardar el resultado de una partida
  Future<void> saveGameResult({
    required String uid,
    required int nivel,
    required bool completado,
    required int aciertos,
    required int errores,
    required int pigmentosGanados,
  }) async {
    try {
      if (_db == null) return;
      await _db!
          .collection('users')
          .doc(uid)
          .collection('gameResults')
          .doc('nivel_$nivel')
          .set({
        'nivel': nivel,
        'completado': completado,
        'fecha': FieldValue.serverTimestamp(),
        'aciertos': aciertos,
        'errores': errores,
        'pigmentosGanados': pigmentosGanados,
      });
      print("¡Resultado del nivel $nivel registrado con éxito!");
    } catch (e, stack) {
      await LoggingService.logException(e, stack, reason: 'Fallo al guardar juego para uid: $uid');
    }
  }

  // 4. Modificar vidas de forma atómica
  Future<void> modifyUserLivesAtomic(String uid, int deltaVidas) async {
    try {
      if (_db == null) return;
      await _db!.collection('users').doc(uid).update({
        'lives': FieldValue.increment(deltaVidas),
      });
      print("Vidas modificadas atómicamente ($deltaVidas).");
    } catch (e, stack) {
      await LoggingService.logException(e, stack, reason: 'Error al actualizar vidas para uid: $uid');
    }
  }

  // 5. Sumar o restar pigmentos atómicamente
  Future<void> addPigments(String uid, int cantidad) async {
    try {
      if (_db == null) return;
      await _db!.collection('users').doc(uid).update({
        'pigments': FieldValue.increment(cantidad),
      });
      print("Pigmentos modificados ($cantidad) con éxito.");
    } catch (e, stack) {
      await LoggingService.logException(e, stack, reason: 'Error al actualizar pigmentos para uid: $uid');
    }
  }

  // 6. Incrementar progreso de nivel de forma atómica
  Future<void> markLevelCompleted(String uid, int nivel) async {
    try {
      if (_db == null) return;
      await _db!.collection('users').doc(uid).update({
        'completedLevels': FieldValue.arrayUnion(['nivel_$nivel']),
        'currentLevelReached': FieldValue.increment(1),
        'level': FieldValue.increment(1),
      });
      print("¡Nivel $nivel actualizado de forma atómica!");
    } catch (e, stack) {
      await LoggingService.logException(e, stack, reason: 'Error al marcar nivel completado para uid: $uid');
    }
  }

  // 7. Consulta de ranking (soporta fallback offline)
  Future<List<UserModel>> getTopRanking() async {
    try {
      if (_db == null) return [];
      QuerySnapshot snapshot;
      try {
        snapshot = await _db!
            .collection('users')
            .orderBy('pigments', descending: true)
            .limit(20)
            .get()
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        snapshot = await _db!
            .collection('users')
            .orderBy('pigments', descending: true)
            .limit(20)
            .get(const GetOptions(source: Source.cache));
      }

      return snapshot.docs.map((doc) {
        return _mapToUser(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e, stack) {
      await LoggingService.logException(e, stack, reason: 'Error al obtener el ranking');
      return [];
    }
  }
}
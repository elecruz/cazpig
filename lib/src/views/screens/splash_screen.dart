import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/splash_controller.dart';
import '../../controllers/user_controller.dart';
import 'login_screen.dart';
import 'menu_principal_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashController _controller = SplashController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await UserController().cargarProgresoLocal();
      } catch (e) {
        debugPrint("Error al cargar SharedPreferences: $e");
      }

      _controller.iniciarSimulacionDeCarga(
        onComplete: () async {
          try {
            await UserController().cargarProgresoLocal();
          } catch (e) {
            debugPrint('Error al cargar SharedPreferences: $e');
          }

          if (!mounted) return;
          final user = UserController().currentUser;

          User? firebaseUser;
          if (Firebase.apps.isNotEmpty) {
            try {
              firebaseUser = FirebaseAuth.instance.currentUser;
            } catch (e) {
              debugPrint("No se pudo obtener el usuario de Firebase: $e");
            }
          }

          final tienePerfilGuardado = user.email.isNotEmpty && user.email != 'invitado@correo.com';
          
          Widget destino;
          if (firebaseUser != null || tienePerfilGuardado || user.isOffline) {
            destino = MenuPrincipalScreen(
              correo: firebaseUser?.email ?? user.email,
              edad: user.age,
            );
          } else {
            destino = const LoginScreen();
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => destino),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E272E),
              Color(0xFF6C5CE7),
              Color(0xFF00CE99),
              Color(0xFFFF6EC7),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              int porcentaje = (_controller.progreso * 100).toInt();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/imagenes/icon1.png',
                        width: 400,
                        height: 400,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            "CAZADORES DE PIGMENTOS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 48),

                      Lottie.asset(
                        'assets/spinners/bool.json',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const CircularProgressIndicator(color: Color(0xFF00C897));
                        },
                      ),
                      const SizedBox(height: 48),

                      Text(
                        _controller.mensaje,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          color: Color(0xFFF3F4F6),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/user_controller.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  final String? correo;
  final String? edad;

  const PerfilScreen({
    super.key,
    this.correo,
    this.edad,
  });

  @override
  Widget build(BuildContext context) {
    final userController = UserController();

    return ListenableBuilder(
      listenable: userController,
      builder: (context, child) {
        final user = userController.currentUser;

        final Map<String, Color> avatarBorderColors = {
          "assets/avatar/avatar1.jpeg": Colors.deepOrange.shade400,
          "assets/avatar/avatar2.jpeg": Colors.cyan.shade400,
          "assets/avatar/avatar3.jpeg": Colors.purple.shade400,
          "assets/avatar/avatar4.jpeg": Colors.green.shade400,
          "assets/avatar/avatar5.jpeg": Colors.amber.shade400,
          "assets/avatar/avatar6.jpeg": Colors.pink.shade400,
        };
        final Color avatarColor = avatarBorderColors[user.avatarUrl] ?? Colors.cyan.shade400;

        Color levelColor;
        if (user.level < 5) {
          levelColor = const Color(0xFFCD7F32); // Bronce
        } else if (user.level < 15) {
          levelColor = const Color(0xFFC0C0C0); // Plata
        } else if (user.level < 30) {
          levelColor = const Color(0xFFFFD700); // Oro
        } else {
          levelColor = const Color(0xFF9D4EDD); // Leyenda
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Fondo de Pantalla Principal
              Positioned.fill(
                child: Image.asset(
                  'assets/imagenes/fondo.jpeg',
                  fit: BoxFit.cover,
                ),
              ),

              // Contenido Scrollable
              Positioned.fill(
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),

                        // TARJETA DE PERFIL PRÉMIUM
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xEB1E2536),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: const Color(0xFFFFD580), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: avatarColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // FILA SUPERIOR: AVATAR + NOMBRE/RANGO + BOTÓN LOGOUT
                              Row(
                                children: [
                                  // AVATAR CON ANILLO LUMINOSO
                                  GestureDetector(
                                    onTap: () => _mostrarGaleriaAvatares(context, userController),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: SweepGradient(
                                              colors: [
                                                avatarColor,
                                                const Color(0xFFFFD580),
                                                avatarColor,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: avatarColor.withValues(alpha: 0.6),
                                                blurRadius: 14,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 41,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(user.avatarUrl),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF6C5CE7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // NOMBRE, TÍTULO Y NIVEL
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name.isEmpty ? 'Jugador' : user.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFFFD580),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // BADGE DE NIVEL
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: levelColor,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: levelColor.withValues(alpha: 0.5),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            'NIVEL ${user.level}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // BOTÓN DE SALIDA COMPACTO
                                  IconButton(
                                    icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                                    tooltip: 'Cerrar sesión',
                                    onPressed: () async {
                                      await AuthService().signOut();
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // FILA DE ESTADÍSTICAS DEL JUGADOR
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem('XP Total', '${user.xp}', Icons.star_rounded, const Color(0xFFFFD580)),
                                    _buildStatDivider(),
                                    _buildStatItem('Vidas', '${user.lives}', Icons.favorite_rounded, const Color(0xFFFF4B4B)),
                                    _buildStatDivider(),
                                    _buildStatItem('Pigmentos', '${user.pigments}', Icons.diamond_rounded, const Color(0xFF00C897)),
                                    _buildStatDivider(),
                                    _buildStatItem('Racha', '${user.streak}d', Icons.local_fire_department_rounded, const Color(0xFFFF9F1C)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // SECCIÓN DE LOGROS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "🏆 Logros Desbloqueados",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                              ),
                            ),
                            Text(
                              "${user.badges.length}/11",
                              style: const TextStyle(
                                color: Color(0xFFFFD580),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // REJILLA DE LOGROS PRÉMIUM
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildBadge(
                              icon: Icons.brush_rounded,
                              title: "Primer Trazo",
                              color: Colors.greenAccent,
                              isUnlocked: user.badges.contains("Primer Trazo"),
                            ),
                            _buildBadge(
                              icon: Icons.local_fire_department_rounded,
                              title: "Racha Color",
                              color: Colors.orangeAccent,
                              isUnlocked: user.badges.contains("Racha Color"),
                            ),
                            _buildBadge(
                              icon: Icons.school_rounded,
                              title: "Estudiante Estrella",
                              color: Colors.purpleAccent,
                              isUnlocked: user.badges.contains("Estudiante Estrella"),
                            ),
                            _buildBadge(
                              icon: Icons.shield_rounded,
                              title: "Sin Mancharse",
                              color: Colors.cyanAccent,
                              isUnlocked: user.badges.contains("Sin Mancharse"),
                            ),
                            _buildBadge(
                              icon: Icons.visibility_rounded,
                              title: "Ojo Entrenado",
                              color: Colors.tealAccent,
                              isUnlocked: user.badges.contains("Ojo Entrenado"),
                            ),
                            _buildBadge(
                              icon: Icons.auto_awesome_rounded,
                              title: "Ojo Mágico",
                              color: Colors.deepPurpleAccent,
                              isUnlocked: user.badges.contains("Ojo Mágico"),
                            ),
                            _buildBadge(
                              icon: Icons.military_tech_rounded,
                              title: "Cazador Definitivo",
                              color: Colors.amberAccent,
                              isUnlocked: user.badges.contains("Cazador Definitivo"),
                            ),
                            _buildBadge(
                              icon: Icons.bolt_rounded,
                              title: "Velocidad Luz",
                              color: Colors.lightBlueAccent,
                              isUnlocked: user.badges.contains("Velocidad luz"),
                            ),
                            _buildBadge(
                              icon: Icons.psychology_rounded,
                              title: "En La Zona",
                              color: Colors.redAccent,
                              isUnlocked: user.badges.contains("En la zona"),
                            ),
                            _buildBadge(
                              icon: Icons.biotech_rounded,
                              title: "Prueba y Error",
                              color: const Color(0xFF50C878),
                              isUnlocked: user.badges.contains("Prueba y error"),
                            ),
                            _buildBadge(
                              icon: Icons.straighten_rounded,
                              title: "Línea Recta",
                              color: Colors.yellowAccent,
                              isUnlocked: user.badges.contains("Linea Recta"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String title,
    required Color color,
    required bool isUnlocked,
  }) {
    final Color backgroundColor = isUnlocked
        ? color.withValues(alpha: 0.18)
        : const Color(0xFF1E2536).withValues(alpha: 0.6);
    final Color iconColor = isUnlocked ? color : Colors.grey.shade600;
    final Color textColor = isUnlocked ? Colors.white : Colors.grey.shade500;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: Border.all(
          color: isUnlocked ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? icon : Icons.lock_rounded,
            size: 34,
            color: iconColor,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarGaleriaAvatares(BuildContext context, UserController controller) {
    final List<String> avataresDisponibles = [
      "assets/avatar/avatar1.jpeg",
      "assets/avatar/avatar2.jpeg",
      "assets/avatar/avatar3.jpeg",
      "assets/avatar/avatar4.jpeg",
      "assets/avatar/avatar5.jpeg",
      "assets/avatar/avatar6.jpeg",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2536),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Selecciona tu Avatar",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: avataresDisponibles.length,
                itemBuilder: (context, index) {
                  final avatar = avataresDisponibles[index];
                  final bool esActual = controller.currentUser.avatarUrl == avatar;

                  return GestureDetector(
                    onTap: () async {
                      await controller.actualizarPerfil(
                        nuevoNombre: controller.currentUser.name,
                        nuevoAvatar: avatar,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: esActual ? const Color(0xFFFFD580) : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(avatar),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
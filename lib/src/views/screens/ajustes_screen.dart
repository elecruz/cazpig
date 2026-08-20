import 'package:flutter/material.dart';
import '../../controllers/game_settings_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/notification_service.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final GameSettingsController _controller = GameSettingsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final settings = _controller.settings;

        return Stack(
          children: [
            // Fondo general
            Positioned.fill(
              child: Image.asset(
                'assets/imagenes/fondo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Título con resplandor
                      const Row(
                        children: [
                          Icon(Icons.settings_rounded, color: Color(0xFFFFD580), size: 28),
                          SizedBox(width: 10),
                          Text(
                            "Ajustes de Juego",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SECCIÓN 1: AUDIO Y EFECTOS
                      _buildSectionHeader("AUDIO Y EFECTOS"),
                      const SizedBox(height: 8),
                      _buildSettingsCard(
                        children: [
                          _buildSwitchTile(
                            title: 'Música de Fondo',
                            subtitle: 'Melodías ambientales de laboratorio',
                            icon: Icons.music_note_rounded,
                            value: settings.musicActive,
                            onChanged: (value) => _controller.setMusicActive(value),
                          ),
                          _buildDivider(),
                          _buildSwitchTile(
                            title: 'Vibración Táctil',
                            subtitle: 'Efectos hápticos al acertar o fallar',
                            icon: Icons.vibration_rounded,
                            value: settings.vibrationActive,
                            onChanged: (value) => _controller.setVibrationActive(value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // SECCIÓN 2: NOTIFICACIONES E IDIOMA
                      _buildSectionHeader("PREFERENCIAS"),
                      const SizedBox(height: 8),
                      _buildSettingsCard(
                        children: [
                          _buildSwitchTile(
                            title: 'Alertas de Desafíos',
                            subtitle: 'Recordatorios para cazar nuevos pigmentos',
                            icon: Icons.notifications_active_rounded,
                            value: settings.notificationsActive,
                            onChanged: (value) async {
                              _controller.setNotificationsActive(value);
                              await NotificationService.toggleNotifications(value);
                            },
                          ),
                          _buildDivider(),
                          _buildInfoTile(
                            title: 'Idioma del Juego',
                            icon: Icons.translate_rounded,
                            value: settings.language,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // SECCIÓN 3: MODO OFFLINE Y NUBE
                      _buildSectionHeader("MODO DE JUEGO Y RED"),
                      const SizedBox(height: 8),
                      ListenableBuilder(
                        listenable: UserController(),
                        builder: (context, _) {
                          final user = UserController().currentUser;
                          return _buildSettingsCard(
                            children: [
                              _buildSwitchTile(
                                title: 'Modo Offline',
                                subtitle: user.isOffline
                                    ? 'Guardando progreso localmente en tu dispositivo'
                                    : 'Sincronizando automáticamente con la nube',
                                icon: user.isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                                value: user.isOffline,
                                onChanged: (value) async {
                                  await UserController().cambiarModoOffline(value);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value
                                            ? 'Modo Offline activado: Tu progreso se guardará en este dispositivo.'
                                            : 'Modo Online activado: Conectado para respaldar en la nube.'),
                                        backgroundColor: value ? Colors.orange : Colors.green,
                                      ),
                                    );
                                  }
                                },
                              ),
                              _buildDivider(),
                              ListTile(
                                leading: const Icon(Icons.sync_rounded, color: Colors.cyanAccent),
                                title: const Text(
                                  'Sincronizar Progreso con la Nube',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                ),
                                subtitle: Text(
                                  user.email.isEmpty || user.email == 'invitado@correo.com'
                                      ? 'Inicia sesión para poder respaldar tu avance'
                                      : 'Subir cambios acumulados a Firebase',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.cyanAccent),
                                onTap: () async {
                                  final exito = await UserController().sincronizarProgresoOfflineConNube();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(exito
                                            ? '¡Progreso sincronizado exitosamente con la nube!'
                                            : 'No se pudo sincronizar. Verifica tu conexión a internet.'),
                                        backgroundColor: exito ? Colors.green : Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // SECCIÓN DANGER: REINICIAR PROGRESO
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _mostrarConfirmacionReinicio(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.delete_forever_rounded, size: 22),
                          label: const Text(
                            "REINICIAR TODO EL PROGRESO",
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      Center(
                        child: Text(
                          'Cazadores de Pigmentos v1.0.0',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFFD580),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEB1E2536),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      secondary: Icon(icon, color: Colors.cyanAccent),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.cyanAccent,
      inactiveTrackColor: Colors.grey.shade800,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
      trailing: Text(value, style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold)),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.08),
      indent: 16,
      endIndent: 16,
    );
  }

  void _mostrarConfirmacionReinicio(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2536),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 12),
              Text("¿Confirmar Reinicio?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Esta acción borrará todo tu progreso local y de la nube (niveles, XP, pigmentos y rachas). Esto no se puede deshacer.",
            style: TextStyle(color: Color(0xFF90A4AE), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await UserController().reiniciarTodoElProgreso();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Progreso reiniciado con éxito"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text("Sí, reiniciar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}
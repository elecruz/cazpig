import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/user_controller.dart';
import '../../widgets/custom_check_button.dart';
import '../../widgets/game_bottom_sheet.dart';
import '../../../controllers/base_level_controller.dart';
import '../../../controllers/level_generator.dart';
import '../../../models/level_model.dart';

class BaseGameplayScreen<T extends LevelModel, C extends BaseLevelController<T>> extends StatefulWidget {
  final int nivel;
  final C Function(BuildContext context) controllerFactory;
  final Widget Function(BuildContext context, C controller) gameFieldBuilder;
  final Widget Function(BuildContext context, C controller)? instructionCardBuilder;
  final bool ocultarBotonComprobar;

  const BaseGameplayScreen({
    super.key,
    required this.nivel,
    required this.controllerFactory,
    required this.gameFieldBuilder,
    this.instructionCardBuilder,
    this.ocultarBotonComprobar = false,
  });

  @override
  State<BaseGameplayScreen<T, C>> createState() => _BaseGameplayScreenState<T, C>();
}

class _BaseGameplayScreenState<T extends LevelModel, C extends BaseLevelController<T>> extends State<BaseGameplayScreen<T, C>> {
  late C _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _comprobar() {
    final bool correcto = _controller.comprobarResultado();

    if (correcto) {
      UserController().completarNivel(widget.nivel);
      final String fact = LevelGenerator.obtenerDatoCurioso(_controller.datosNivel);
      GameBottomSheet.mostrarVictoria(
        context: context,
        pigmentosGanados: 30,
        datoCurioso: fact,
        onContinuar: () {
          Navigator.pop(context);
        },
      );
    } else {
      UserController().restarVida();
      final livesLeft = UserController().currentUser.lives;
      final String mensajeError = _obtenerMensajeError(_controller.datosNivel);

      GameBottomSheet.mostrarDerrota(
        context: context,
        mensaje: livesLeft <= 0
            ? "Te has quedado sin vidas. ¡Repón vidas en el mapa!"
            : mensajeError,
        onReintentar: () {
          if (livesLeft <= 0) {
            Navigator.pop(context);
          } else {
            setState(() {
              _controller = widget.controllerFactory(context);
            });
          }
        },
        onVolver: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double ancho = MediaQuery.of(context).size.width;
    final bool esPantallaAncha = ancho > 600;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final datos = _controller.datosNivel;

        return Stack(
          children: [
            // Fondo unificado de juego
            Positioned.fill(
              child: Image.asset(
                'assets/imagenes/pantallajuego.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: Color(0xFFFFD580),
                  size: 28,
                ),
                title: Text(
                  '${datos.title} - Nivel ${datos.level}',
                  style: const TextStyle(
                    color: Color(0xFFFFE4A3),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ListenableBuilder(
                    listenable: UserController(),
                    builder: (context, child) {
                      final user = UserController().currentUser;
                      return Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: Color(0xFFFF4B4B), size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${user.lives}',
                            style: const TextStyle(
                              color: Color(0xFFFFE4A3),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.diamond_rounded, color: Color(0xFF00C897), size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${user.pigments}',
                            style: const TextStyle(
                              color: Color(0xFFFFE4A3),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Flex(
                        direction: esPantallaAncha ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: esPantallaAncha ? ancho * 0.45 : double.infinity,
                            child: widget.instructionCardBuilder != null
                                ? widget.instructionCardBuilder!(context, _controller)
                                : _buildDefaultInstructionCard(datos),
                          ),
                          const SizedBox(height: 16, width: 16),
                          SizedBox(
                            width: esPantallaAncha ? ancho * 0.45 : double.infinity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFA141C28),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black87,
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  widget.gameFieldBuilder(context, _controller),
                                  if (!widget.ocultarBotonComprobar) ...[
                                    const SizedBox(height: 16),
                                    CustomCheckButton(
                                      habilitado: _controller.listoParaComprobar,
                                      onPressed: _comprobar,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _obtenerMensajeError(LevelModel model) {
    if (model is ContrastLevelModel) {
      return model.explanation;
    }
    if (model is BlindLevelModel) {
      return model.explanation;
    }
    if (model is MixLevelModel) {
      return "Mezclar pigmentos físicos es sustractivo: busca qué dos reactivos combinados forman el tono objetivo (los primarios son azul, amarillo y rojo).";
    }
    if (model is SearchLevelModel) {
      return "El tono solicitado responde a la psicología del color. Elige el matiz que exprese mejor la emoción del brief.";
    }
    if (model is GradientLevelModel) {
      return "El color correcto debe encajar de forma suave y progresiva en la escala cromática sin romper la gradación visual.";
    }
    if (model is HarmonyLevelModel) {
      return "La respuesta correcta debe formar la relación geométrica solicitada: el complementario (opuesto) o análogo (color vecino en el círculo).";
    }
    if (model is RgbLevelModel) {
      return "El color resultante de tu mezcla difiere del objetivo. Ajusta los canales R, G y B guiándote por el medidor de similitud.";
    }
    if (model is TempLevelModel) {
      return "¡Cuidado! Clasifica los cálidos (rojo, naranja, amarillo) en el frasco izquierdo y los fríos (azul, verde, violeta) en el derecho.";
    }
    if (model is HexLevelModel) {
      return "El código hexadecimal #RRGGBB representa la intensidad del Rojo, Verde y Azul. Compara las muestras con el código dado.";
    }
    if (model is AlbersLevelModel) {
      return model.explanation;
    }
    if (model is AtmosphereLevelModel) {
      return "La paleta correcta debe ser coherente con la temática y las emociones del brief cinematográfico solicitado.";
    }
    if (model is SaturationLevelModel) {
      return "El orden secuencial correcto debe ir de menor a mayor pureza: desde el color más grisáceo hasta el tono más puro y vivo.";
    }
    return "Esa no es la respuesta correcta. ¡Inténtalo de nuevo!";
  }

  Widget _buildDefaultInstructionCard(LevelModel datos) {
    String subtitle = "";
    String title = datos.title;

    if (datos is MixLevelModel) {
      subtitle = datos.objective;
      title = "OBJETIVO";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFA141C28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD580), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 14,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFFD580),
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.2,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            datos.instruction,
            style: const TextStyle(
              color: Color(0xFFFFE4A3),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black, blurRadius: 3)],
            ),
          ),
        ],
      ),
    );
  }
}
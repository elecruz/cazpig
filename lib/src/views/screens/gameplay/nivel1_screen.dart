import 'package:flutter/material.dart';
import '../../../controllers/nivel1_controller.dart';
import '../../../models/level_model.dart';
import '../../widgets/custom_check_button.dart';
import 'base_gameplay_screen.dart';

class Nivel1Screen extends StatelessWidget {
  final int nivelInicial;

  const Nivel1Screen({super.key, required this.nivelInicial});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo del juego
        Positioned.fill(
          child: Image.asset(
            'assets/imagenes/pantallajuego.jpeg',
            fit: BoxFit.cover,
          ),
        ),

        // Capa interactiva
        BaseGameplayScreen<MixLevelModel, Nivel1Controller>(
          nivel: nivelInicial,
          ocultarBotonComprobar: true,
          controllerFactory: (context) => Nivel1Controller(nivelInicial: nivelInicial),
          gameFieldBuilder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _construirMatrazLaboratorio(
                      controller.colorSeleccionado1,
                      "Matraz Fusión 1",
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "+",
                        style: TextStyle(
                          color: Color(0xFFFFD580),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                    _construirMatrazLaboratorio(
                      controller.colorSeleccionado2,
                      "Matraz Fusión 2",
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                if (controller.listoParaComprobar) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xEB22140A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.colorResultante,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: controller.colorResultante.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Resultado: ",
                          style: TextStyle(
                            color: Color(0xFFFFE4A3),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: controller.colorResultante,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.nombreColorResultante,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  const SizedBox(height: 46),
                ],

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Selecciona dos pigmentos para mezclar:",
                    style: TextStyle(
                      color: Color(0xFFFFE4A3),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: controller.opcionesPaleta.map((pigmento) {
                    final Color col = pigmento.color;
                    final bool seleccionado =
                        controller.colorSeleccionado1 == col ||
                        controller.colorSeleccionado2 == col;

                    return GestureDetector(
                      onTap: () => controller.seleccionarColor(col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 145,
                        height: 92,
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? const Color(0xF03D2314)
                              : const Color(0xD91E130D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: seleccionado
                                ? const Color(0xFFFFD580)
                                : const Color(0xFF6E4627),
                            width: seleccionado ? 2.8 : 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: seleccionado
                                  ? col.withOpacity(0.5)
                                  : Colors.black54,
                              blurRadius: seleccionado ? 10 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: col, width: 1.5),
                                  ),
                                  child: Icon(Icons.science, color: col, size: 18),
                                ),
                                Icon(Icons.colorize, color: col.withOpacity(0.8), size: 16),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${pigmento.formula}  #${col.value.toRadixString(16).substring(2).toUpperCase()}",
                                  style: TextStyle(
                                    color: const Color(0xFFFFE4A3).withOpacity(0.8),
                                    fontSize: 9,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pigmento.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(color: Colors.black, blurRadius: 4),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                if (controller.colorSeleccionado1 != null ||
                    controller.colorSeleccionado2 != null)
                  TextButton.icon(
                    onPressed: () => controller.reiniciarSeleccion(),
                    icon: const Icon(Icons.refresh, color: Color(0xFFFF7B7B), size: 18),
                    label: const Text(
                      "Limpiar Matraces",
                      style: TextStyle(
                        color: Color(0xFFFF7B7B),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 44),

                const SizedBox(height: 6),

                CustomCheckButton(
                  habilitado: controller.listoParaComprobar,
                  onPressed: () {
                    controller.comprobarResultado();
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _construirMatrazLaboratorio(Color? color, String tag) {
    final bool estaLleno = color != null;

    return Column(
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            // Fondo opaco sólido oscuro para bloquear por completo el fondo
            color: const Color(0xFF140C07),
            shape: BoxShape.circle,
            border: Border.all(
              color: estaLleno ? color : const Color(0xFF8B5A2B),
              width: estaLleno ? 4.0 : 2.5,
            ),
            boxShadow: [
              // Sombra negra sólida de fondo para despegarlo del arte
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
              // Brillo de color
              if (estaLleno)
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Relleno de color con fondo seguro
              if (estaLleno)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              // Icono con sombra para máximo contraste
              Icon(
                estaLleno
                    ? Icons.hourglass_full_rounded
                    : Icons.hourglass_empty_rounded,
                color: estaLleno ? color : const Color(0xFFFFD580),
                size: 38,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xEB140C07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF8B5A2B),
              width: 1.2,
            ),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: Color(0xFFFFE4A3),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../controllers/nivel12_controller.dart';
import '../../../models/level_model.dart';
import '../../widgets/game_button.dart';
import 'base_gameplay_screen.dart';

class Nivel12Screen extends StatelessWidget {
  final int nivelInicial;

  const Nivel12Screen({super.key, required this.nivelInicial});

  Color _getShadowColor(Color color) {
    return Color.fromARGB(
      (color.a * 255.0).round().clamp(0, 255),
      (color.r * 255.0 * 0.7).round().clamp(0, 255),
      (color.g * 255.0 * 0.7).round().clamp(0, 255),
      (color.b * 255.0 * 0.7).round().clamp(0, 255),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseGameplayScreen<SaturationLevelModel, Nivel12Controller>(
      nivel: nivelInicial,
      controllerFactory: (context) => Nivel12Controller(nivelInicial: nivelInicial),
      gameFieldBuilder: (context, controller) {
        final datosNivel = controller.datosNivel;

        return Column(
          children: [
            // SECUENCIA RESULTADO (ORDEN CREADO)
            const Text(
              "SECUENCIA DE ORDENAMIENTO (De desaturado a saturado):",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFFFE4A3), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(datosNivel.sequence.length, (idx) {
                  final Color? color = idx < controller.seleccion.length ? controller.seleccion[idx] : null;

                  return GestureDetector(
                    onTap: () {
                      if (color != null) {
                        controller.toggleColor(color);
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: color ?? const Color(0xFF141824),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: color != null ? const Color(0xFF8B5A2B) : const Color(0xFF3F4B62),
                          width: color != null ? 2.0 : 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: color == null
                          ? Text(
                              "${idx + 1}",
                              style: const TextStyle(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.bold),
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            // OPCIONES DISPONIBLES
            const Text(
              "PIGMENTOS DESORDENADOS EN LA MESA:",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFFFE4A3), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: datosNivel.shuffled.map((color) {
                final bool seleccionado = controller.seleccion.contains(color);

                return Opacity(
                  opacity: seleccionado ? 0.35 : 1.0,
                  child: GameButton(
                    width: 58,
                    height: 58,
                    borderRadius: 14,
                    backgroundColor: color,
                    shadowColor: _getShadowColor(color),
                    onTap: () => controller.toggleColor(color),
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "#${color.value.toRadixString(16).substring(2).toUpperCase()}",
                          style: const TextStyle(color: Colors.white, fontSize: 7.5, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

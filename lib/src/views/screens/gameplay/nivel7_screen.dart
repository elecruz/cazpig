import 'package:flutter/material.dart';
import '../../../controllers/nivel7_controller.dart';
import '../../../models/level_model.dart';
import '../../widgets/nivel7_widgets.dart';
import 'base_gameplay_screen.dart';

class Nivel7Screen extends StatelessWidget {
  final int nivelInicial;

  const Nivel7Screen({
    super.key,
    required this.nivelInicial,
  });

  String _hex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return BaseGameplayScreen<RgbLevelModel, Nivel7Controller>(
      nivel: nivelInicial,
      controllerFactory: (context) => Nivel7Controller(nivelInicial: nivelInicial),
      gameFieldBuilder: (context, controller) {
        final RgbLevelModel datos = controller.datosNivel;

        return Column(
          children: [
            // Comparación de tonos (Objetivo vs Tu Mezcla)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PortalColorWidget(
                  color: datos.targetColor,
                  title: datos.targetColorName,
                  hex: _hex(datos.targetColor),
                ),
                SizedBox(
                  width: 48,
                  height: 60,
                  child: Image.asset(
                    'assets/imagenes/cuerda.png',
                    fit: BoxFit.contain,
                  ),
                ),
                PortalColorWidget(
                  color: controller.currentColor,
                  title: 'TU MEZCLA',
                  hex: _hex(controller.currentColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Brújula de Similitud
            MedidorSimilitudWidget(
              similarity: controller.similarity,
              feedbackMessage: controller.feedbackMessage,
            ),
            const SizedBox(height: 12),

            // Cañones RGB
            CanalRgbSliderWidget(
              label: 'CAÑÓN ROJO (R)',
              value: controller.r,
              color: Colors.redAccent,
              onChanged: controller.updateRed,
            ),
            const SizedBox(height: 6),
            CanalRgbSliderWidget(
              label: 'CAÑÓN VERDE (G)',
              value: controller.g,
              color: Colors.greenAccent,
              onChanged: controller.updateGreen,
            ),
            const SizedBox(height: 6),
            CanalRgbSliderWidget(
              label: 'CAÑÓN AZUL (B)',
              value: controller.b,
              color: Colors.blueAccent,
              onChanged: controller.updateBlue,
            ),
          ],
        );
      },
    );
  }
}
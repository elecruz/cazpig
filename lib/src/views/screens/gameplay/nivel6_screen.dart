import 'package:flutter/material.dart';
import '../../../controllers/nivel6_controller.dart';
import '../../../models/level_model.dart';
import '../../widgets/nivel6_widgets.dart';
import 'base_gameplay_screen.dart';

class Nivel6Screen extends StatefulWidget {
  final int nivelInicial;

  const Nivel6Screen({
    super.key,
    required this.nivelInicial,
  });

  @override
  State<Nivel6Screen> createState() => _Nivel6ScreenState();
}

class _Nivel6ScreenState extends State<Nivel6Screen> {
  String _activeSimulacion = 'Protanopia';

  String _getNombreColor(Color color) {
    final int value = color.value & 0xFFFFFF;
    if (value == 0xE53935) return 'ROJO CADMIO';
    if (value == 0x43A047) return 'VERDE VIRIDIÁN';
    if (value == 0x795548) return 'MARRÓN TIERRA';
    if (value == 0xFFFFB300) return 'AMARILLO CROMO';
    if (value == 0xFFC62828) return 'ROJO OSCURO';
    if (value == 0xFF0288D1) return 'CELESTE';
    if (value == 0xFFD84315) return 'NARANJA OSCURO';
    if (value == 0xFF757575) return 'GRIS';
    if (value == 0xFFC2185B) return 'MAGENTA';
    if (value == 0xFF6A1B9A) return 'PÚRPURA';
    if (value == 0xFF558B2F) return 'VERDE OLIVA';
    if (value == 0xFF1976D2) return 'AZUL REY';
    if (value == 0xFFEF6C00) return 'NARANJA';
    if (value == 0xFF00ACC1) return 'TURQUESA';
    return 'COLOR';
  }

  List<double> _getMatrixForType(String tipo) {
    if (tipo == 'Protanopia') {
      return const [
        0.567, 0.433, 0.0,   0.0, 0.0,
        0.558, 0.442, 0.0,   0.0, 0.0,
        0.0,   0.242, 0.758, 0.0, 0.0,
        0.0,   0.0,   0.0,   1.0, 0.0,
      ];
    } else if (tipo == 'Deuteranopia') {
      return const [
        0.625, 0.375, 0.0,   0.0, 0.0,
        0.7,   0.3,   0.0,   0.0, 0.0,
        0.0,   0.3,   0.7,   0.0, 0.0,
        0.0,   0.0,   0.0,   1.0, 0.0,
      ];
    } else {
      return const [
        0.95,  0.05,  0.0,   0.0, 0.0,
        0.0,   0.433, 0.567, 0.0, 0.0,
        0.0,   0.475, 0.525, 0.0, 0.0,
        0.0,   0.0,   0.0,   1.0, 0.0,
      ];
    }
  }

  bool _aplicarFiltroAOpciones = false;

  @override
  Widget build(BuildContext context) {
    return BaseGameplayScreen<BlindLevelModel, Nivel6Controller>(
      nivel: widget.nivelInicial,
      controllerFactory: (context) => Nivel6Controller(nivelInicial: widget.nivelInicial),
      gameFieldBuilder: (context, controller) {
        final BlindLevelModel datos = controller.datosNivel;
        final List<double> matrixActual = _getMatrixForType(_activeSimulacion);
        final Color colorAAplicar = controller.colorSeleccionado ?? datos.targetColor;

        return Column(
          children: [
            // Filtros de Daltonismo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FiltroDaltonismoButton(
                  label: 'PROTANOPIA',
                  value: 'Protanopia',
                  activo: _activeSimulacion == 'Protanopia',
                  onTap: () => setState(() => _activeSimulacion = 'Protanopia'),
                ),
                FiltroDaltonismoButton(
                  label: 'DEUTERANOPIA',
                  value: 'Deuteranopia',
                  activo: _activeSimulacion == 'Deuteranopia',
                  onTap: () => setState(() => _activeSimulacion = 'Deuteranopia'),
                ),
                FiltroDaltonismoButton(
                  label: 'TRITANOPIA',
                  value: 'Tritanopia',
                  activo: _activeSimulacion == 'Tritanopia',
                  onTap: () => setState(() => _activeSimulacion = 'Tritanopia'),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Ojos de Simulación (Vistos bajo filtro)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                VisualizadorOjoWidget(
                  label: 'OBJETIVO REAL',
                  child: Container(color: datos.targetColor),
                ),
                VisualizadorOjoWidget(
                  label: controller.colorSeleccionado != null
                      ? 'TU ELECCIÓN CON $_activeSimulacion'
                      : 'OBJETIVO CON $_activeSimulacion',
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(matrixActual),
                    child: Container(color: colorAAplicar),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Interruptor para simular lente daltonizado en las opciones
            FilterChip(
              label: Text(
                _aplicarFiltroAOpciones ? "Lente de $_activeSimulacion: ACTIVADO" : "Probar Lente en Muestras",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              selected: _aplicarFiltroAOpciones,
              selectedColor: const Color(0xFFFFD580),
              checkmarkColor: const Color(0xFF141C28),
              onSelected: (val) => setState(() => _aplicarFiltroAOpciones = val),
            ),
            const SizedBox(height: 12),

            // Selector de Muestras de Color
            const Text(
              "Elige la muestra original que produce este tono:",
              style: TextStyle(
                color: Color(0xFFFFE4A3),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: datos.options.length,
              itemBuilder: (context, index) {
                final Color optionColor = datos.options[index];
                final bool seleccionado = controller.colorSeleccionado == optionColor;

                Widget card = OpcionPigmentoCardWidget(
                  color: optionColor,
                  nombre: _getNombreColor(optionColor),
                  seleccionado: seleccionado,
                  onTap: () => controller.seleccionarColor(optionColor),
                );

                if (_aplicarFiltroAOpciones) {
                  card = ColorFiltered(
                    colorFilter: ColorFilter.matrix(matrixActual),
                    child: card,
                  );
                }

                return card;
              },
            ),
          ],
        );
      },
    );
  }
}
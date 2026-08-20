import 'package:flutter/material.dart';
import '../../../controllers/nivel8_controller.dart';
import '../../../models/level_model.dart';
import '../../widgets/nivel8_widgets.dart';
import 'base_gameplay_screen.dart';

class Nivel8Screen extends StatelessWidget {
  final int nivelInicial;

  const Nivel8Screen({
    super.key,
    required this.nivelInicial,
  });

  static const List<String> _imagenesCalidas = [
    'assets/imagenes/lingote_amarillo.png',
    'assets/imagenes/lingote_naranja.png',
  ];

  static const List<String> _imagenesFrias = [
    'assets/imagenes/polvo_azul.png',
    'assets/imagenes/polvo_turquesa.png',
  ];

  bool _esCalido(Color color, TempLevelModel datos) {
    return datos.warmColors.any((item) => item.value == color.value);
  }

  String _imagenDelPigmento(Color color, TempLevelModel datos) {
    final bool esCalido = _esCalido(color, datos);
    final List<Color> colores = esCalido ? datos.warmColors : datos.coldColors;
    final List<String> imagenes = esCalido ? _imagenesCalidas : _imagenesFrias;
    final int index = colores.indexWhere((item) => item.value == color.value);
    if (index >= 0 && index < imagenes.length) {
      return imagenes[index];
    }
    return imagenes.first;
  }

  @override
  Widget build(BuildContext context) {
    return BaseGameplayScreen<TempLevelModel, Nivel8Controller>(
      nivel: nivelInicial,
      controllerFactory: (context) => Nivel8Controller(nivelInicial: nivelInicial),
      gameFieldBuilder: (context, controller) {
        final datos = controller.datosNivel;
        final List<Color> allColors = List<Color>.from(datos.allOptions);

        return Column(
          children: [
            // Botines de Color - Muestras Disponibles
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xEB140C07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'BOTINES DE COLOR (Desliza o toca un pigmento)',
                    style: TextStyle(
                      color: Color(0xFFFFE4A3),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: allColors.map((color) {
                      final bool disponible = controller.available.any((item) => item.value == color.value);
                      if (!disponible) return const SizedBox.shrink();

                      final String imgPath = _imagenDelPigmento(color, datos);

                      return GestureDetector(
                        onTap: () => _mostrarConsultaCofre(context, color, controller),
                        child: Draggable<Color>(
                          data: color,
                          feedback: PigmentItemWidget(
                            color: color,
                            imagePath: imgPath,
                            size: 76,
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.25,
                            child: PigmentItemWidget(
                              color: color,
                              imagePath: imgPath,
                              size: 60,
                            ),
                          ),
                          child: PigmentItemWidget(
                            color: color,
                            imagePath: imgPath,
                            size: 60,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Zonas de Clasificación (Cálidos / Fríos)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Nivel8DropZoneWidget(
                  zone: 'warm',
                  colors: controller.warm,
                  borderColor: const Color(0xFFD77A3B),
                  controller: controller,
                  getImagePath: (c) => _imagenDelPigmento(c, datos),
                ),
                const SizedBox(width: 12),
                Nivel8DropZoneWidget(
                  zone: 'cold',
                  colors: controller.cold,
                  borderColor: const Color(0xFF73B8D8),
                  controller: controller,
                  getImagePath: (c) => _imagenDelPigmento(c, datos),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _mostrarConsultaCofre(BuildContext context, Color color, Nivel8Controller controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2536),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "¿A qué cofre pertenece este pigmento?",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD77A3B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.wb_sunny_rounded, color: Colors.white),
                      label: const Text("Cálido (Sol)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        controller.classifyColor(color, 'warm');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B9AD7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.ac_unit_rounded, color: Colors.white),
                      label: const Text("Frío (Hielo)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        controller.classifyColor(color, 'cold');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
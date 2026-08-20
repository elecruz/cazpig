import 'package:flutter/material.dart';
import '../../controllers/nivel8_controller.dart';

/// Widget de ficha individual de pigmento para Nivel 8
class PigmentItemWidget extends StatelessWidget {
  final Color color;
  final String imagePath;
  final double size;
  final bool enSaco;
  final bool esCalido;

  const PigmentItemWidget({
    super.key,
    required this.color,
    required this.imagePath,
    required this.size,
    this.enSaco = false,
    this.esCalido = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imagen = Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (enSaco && !esCalido) {
      imagen = Align(
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: const Offset(9, -30),
          child: imagen,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: size,
        height: size,
        child: (esCalido || !enSaco)
            ? Center(child: imagen)
            : imagen,
      ),
    );
  }
}

/// Zona de arrastre (Cajas Sol / Fría)
class Nivel8DropZoneWidget extends StatelessWidget {
  final String zone;
  final List<Color> colors;
  final Color borderColor;
  final Nivel8Controller controller;
  final String Function(Color color) getImagePath;

  const Nivel8DropZoneWidget({
    super.key,
    required this.zone,
    required this.colors,
    required this.borderColor,
    required this.controller,
    required this.getImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool zonaCalida = zone == 'warm';

    return Expanded(
      child: DragTarget<Color>(
        onAcceptWithDetails: (details) {
          controller.classifyColor(details.data, zone);
        },
        builder: (context, candidateData, rejectedData) {
          final bool isOver = candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 310,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: isOver ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.45),
                  blurRadius: 16,
                  spreadRadius: 6,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Transform.translate(
                    offset: const Offset(0, -8),
                    child: Image.asset(
                      zonaCalida ? 'assets/imagenes/cajasol.png' : 'assets/imagenes/cajafria.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 74,
                  bottom: 20,
                  child: colors.isEmpty
                      ? const Center(
                          child: Text(
                            'ARRASTRA O\nTOCA AQUÍ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4A2818),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              shadows: [Shadow(color: Color(0xFFFFE4A3), blurRadius: 2)],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(4),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            final Color color = colors[index];
                            return GestureDetector(
                              onTap: () {
                                controller.classifyColor(color, 'available');
                              },
                              child: PigmentItemWidget(
                                color: color,
                                imagePath: getImagePath(color),
                                size: 58,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../controllers/level_generator.dart';
import '../../../controllers/nivel7_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/level_model.dart';
import '../../widgets/game_bottom_sheet.dart';

class Nivel7Screen extends StatefulWidget {
  final int nivelInicial;

  const Nivel7Screen({
    super.key,
    required this.nivelInicial,
  });

  @override
  State<Nivel7Screen> createState() => _Nivel7ScreenState();
}

class _Nivel7ScreenState extends State<Nivel7Screen> {
  late final Nivel7Controller controller =
      Nivel7Controller(nivelInicial: widget.nivelInicial);

  static const Color colorDorado = Color(0xFFFFD580);
  static const Color colorTexto = Color(0xFFFFE4A3);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _hex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _comprobar() {
    final bool correcto = controller.comprobarResultado();

    if (correcto) {
      UserController().completarNivel(widget.nivelInicial);

      GameBottomSheet.mostrarVictoria(
        context: context,
        pigmentosGanados: 30,
        datoCurioso: LevelGenerator.obtenerDatoCurioso(
          controller.datosNivel,
        ),
        onContinuar: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      UserController().restarVida();

      final int vidas = UserController().currentUser.lives;

      GameBottomSheet.mostrarDerrota(
        context: context,
        mensaje: vidas <= 0
            ? 'Te has quedado sin vidas. ¡Repón vidas en el mapa!'
            : 'El color todavía no coincide con el objetivo. Ajusta los cañones RGB.',
        onReintentar: () {
          if (vidas <= 0) {
            Navigator.of(context).pop();
          } else {
            controller.reiniciarSeleccion();
            setState(() {});
          }
        },
        onVolver: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  Widget _buildHeader() {
    final user = UserController().currentUser;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF3B2312),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF8B5A2B),
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            icon: const Icon(
              Icons.arrow_back,
              color: colorDorado,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Text(
              'LABORATORIO RGB - Nivel ${widget.nivelInicial}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: colorDorado,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${user.lives}',
            style: const TextStyle(
              color: colorDorado,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.diamond,
            color: Colors.tealAccent,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${user.pigments}',
            style: const TextStyle(
              color: colorDorado,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionPanel(RgbLevelModel datos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        20,
      ),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/imagenes/ficha.png'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LABORATORIO RGB',
            style: TextStyle(
              color: Color(0xFF3B2312),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            datos.instruction,
            style: const TextStyle(
  color: Color(0xFF2C1A04),
  fontSize: 14,
  height: 1.35,
  fontWeight: FontWeight.w900,
),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPortal({
    required Color color,
    required String title,
    required String hex,
  }) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Círculo más pequeño para que no salga de la rueda.
                Container(
                  width: 98,
                  height: 98,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.7),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),

                // Rueda ampliada: funciona como marco del color.
                Transform.scale(
                  scale: 1.9,
                  child: Image.asset(
                    'assets/imagenes/rueda.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: colorDorado,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hex,
            style: const TextStyle(
              color: colorDorado,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(RgbLevelModel datos) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildColorPortal(
          color: datos.targetColor,
          title: datos.targetColorName,
          hex: _hex(datos.targetColor),
        ),
        SizedBox(
          width: 58,
          height: 70,
          child: Image.asset(
            'assets/imagenes/cuerda.png',
            fit: BoxFit.contain,
          ),
        ),
        _buildColorPortal(
          color: controller.currentColor,
          title: 'TU MEZCLA',
          hex: _hex(controller.currentColor),
        ),
      ],
    );
  }

  Widget _buildSimilarity() {
  final double similarity = controller.similarity;

  return LayoutBuilder(
    builder: (context, constraints) {
      final double panelWidth = constraints.maxWidth;
      final double imageWidth = panelWidth * 1.85;
      final double imageHeight = imageWidth * 256 / 960;

      return SizedBox(
        width: double.infinity,
        height: 170,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -4,
              left: (panelWidth - imageWidth) / 2,
              width: imageWidth,
              height: imageHeight,
              child: Image.asset(
                'assets/imagenes/brujula.png',
                fit: BoxFit.fill,
              ),
            ),

            Positioned(
              left: 42,
              right: 42,
              top: 78,
              bottom: 18,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'SIMILITUD: ${similarity.toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFD580),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      controller.feedbackMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFE4A3),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildCannon({
  required String label,
  required double value,
  required Color color,
  required ValueChanged<double> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Transform.translate(
        offset: const Offset(0, 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$label [${value.toInt()}]',
                  style: const TextStyle(
                    color: Color(0xFFFFD580),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '[${value.toInt()}]',
                style: const TextStyle(
                  color: Color(0xFFFFD580),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 2),
        SizedBox(
          height: 106,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Cañón más grande y visible.
                  Positioned.fill(
                    child: Image.asset(
                      'assets/imagenes/cañon.png',
                      fit: BoxFit.fill,
                    ),
                  ),

                  // El slider empieza ligeramente antes de la boca,
                  // eliminando el espacio muerto entre la boca y la línea.
                  Positioned(
                    left: width * 0.385,
                    right: width * 0.03,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 14,
                        activeTrackColor: color.withOpacity(0.9),
                        inactiveTrackColor: const Color(0xFF3A2015),
                        thumbColor: color,
                        overlayColor: color.withOpacity(0.18),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 15,
                        ),
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: value,
                        min: 0,
                        max: 255,
                        divisions: 255,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton() {
    return Transform.translate(
      offset: const Offset(0, 24),
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/imagenes/cofre.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              left: 48,
              right: 48,
              top: 58,
              bottom: 32,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _comprobar,
                  borderRadius: BorderRadius.circular(25),
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'COMPROBAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFF0A8),
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final RgbLevelModel datos = controller.datosNivel;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/imagenes/fondoagua.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          12,
                          14,
                          4,
                        ),
                        child: Column(
                          children: [
                            _buildInstructionPanel(datos),
                            const SizedBox(height: 18),
                            _buildComparison(datos),
                            const SizedBox(height: 10),
                            _buildSimilarity(),
                            const SizedBox(height: 12),
                            _buildCannon(
                              label: 'CAÑÓN ROJO (R)',
                              value: controller.r,
                              color: Colors.redAccent,
                              onChanged: controller.updateRed,
                            ),
                            const SizedBox(height: 8),
                            _buildCannon(
                              label: 'CAÑÓN VERDE (G)',
                              value: controller.g,
                              color: Colors.greenAccent,
                              onChanged: controller.updateGreen,
                            ),
                            const SizedBox(height: 8),
                            _buildCannon(
                              label: 'CAÑÓN AZUL (B)',
                              value: controller.b,
                              color: Colors.blueAccent,
                              onChanged: controller.updateBlue,
                            ),
                            const SizedBox(height: 0),
                            _buildCheckButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
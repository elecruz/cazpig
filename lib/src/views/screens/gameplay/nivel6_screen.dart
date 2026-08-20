import 'package:flutter/material.dart';
import '../../../controllers/level_generator.dart';
import '../../../controllers/nivel6_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../widgets/game_bottom_sheet.dart';

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
  late final Nivel6Controller controller =
      Nivel6Controller(nivelInicial: widget.nivelInicial);

  String activeSimulacion = 'Protanopia';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Color _getShadowColor(Color color) {
    return Color.fromARGB(
      (color.a * 255).round().clamp(0, 255),
      (color.r * 255 * 0.7).round().clamp(0, 255),
      (color.g * 255 * 0.7).round().clamp(0, 255),
      (color.b * 255 * 0.7).round().clamp(0, 255),
    );
  }

  String _getNombreColor(Color color) {
    final int value = color.value & 0xFFFFFF;

    if (value == 0xE53935) return 'ROJO\nCADMIO';
    if (value == 0x43A047) return 'VERDE\nVIRIDIÁN';
    if (value == 0x795548) return 'MARRÓN\nTIERRA';
    if (value == 0xFFFFB300) return 'AMARILLO\nCROMO';
    if (value == 0xFFC62828) return 'ROJO\nOSCURO';
    if (value == 0xFF0288D1) return 'CELESTE';
    if (value == 0xFFD84315) return 'NARANJA\nOSCURO';
    if (value == 0xFF757575) return 'GRIS';
    if (value == 0xFFC2185B) return 'MAGENTA';
    if (value == 0xFFFFFFFF) return 'BLANCO';
    if (value == 0xFF6A1B9A) return 'PÚRPURA';
    if (value == 0xFF558B2F) return 'VERDE\nOLIVA';
    if (value == 0xFF9E9D24) return 'LIMÓN';
    if (value == 0xFF1976D2) return 'AZUL\nREY';
    if (value == 0xFFEF6C00) return 'NARANJA';
    if (value == 0xFF9E9E9E) return 'GRIS\nCLARO';
    if (value == 0xFF4E342E) return 'CAFÉ';
    if (value == 0xFFFF4081) return 'ROSADO\nNEÓN';
    if (value == 0xFFFFD54F) return 'AMARILLO\nCLARO';
    if (value == 0xFF4A148C) return 'PÚRPURA\nOSCURO';
    if (value == 0xFFFFB74D) return 'NARANJA\nCLARO';
    if (value == 0xFFF8BBD0) return 'ROSADO\nCLARO';
    if (value == 0xFF00ACC1) return 'TURQUESA';
    if (value == 0xFFF4511E) return 'ROJO\nNARANJA';
    if (value == 0xFF4FC3F7) return 'CELESTE\nCLARO';
    if (value == 0xFF4CAF50) return 'VERDE\nCLARO';

    return 'COLOR';
  }

  void _evaluarRespuesta() {
    if (controller.colorSeleccionado == null) return;

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

      final int vidasRestantes = UserController().currentUser.lives;

      setState(() {});

      GameBottomSheet.mostrarDerrota(
        context: context,
        mensaje: vidasRestantes <= 0
            ? 'Te has quedado sin vidas. ¡Repón vidas en el mapa!'
            : controller.datosNivel.explanation,
        onReintentar: () {
          if (vidasRestantes <= 0) {
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

  Widget _buildFilterButton(String label, String value) {
    final bool activo = activeSimulacion == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          activeSimulacion = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: activo
                ? const [
                    Color(0xFFFBE49D),
                    Color(0xFFC89218),
                  ]
                : const [
                    Color(0xFFC3A26B),
                    Color(0xFF7A5A28),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo
                ? const Color(0xFFFFF7C2)
                : const Color(0xFF4A3410),
            width: activo ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: activo
                ? const Color(0xFF2C1A04)
                : const Color(0xFF1E1102),
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildPorthole({
    required Widget child,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE2B755),
                Color(0xFF8A6218),
                Color(0xFF3B2303),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0D171E),
            ),
            child: ClipOval(child: child),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFE2B755),
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    final bool seleccionado = controller.colorSeleccionado == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          controller.seleccionarColor(color);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(22),
            bottom: Radius.circular(16),
          ),
          border: Border.all(
            color: seleccionado
                ? const Color(0xFFFFD700)
                : Colors.black.withOpacity(0.3),
            width: seleccionado ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
            bottom: Radius.circular(14),
          ),
          child: Container(
            color: color,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _getNombreColor(color).replaceAll('\n', ' '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 6,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<double> _getColorMatrix() {
    if (activeSimulacion == 'Protanopia') {
      return const [
        0.567, 0.433, 0.0, 0.0, 0.0,
        0.558, 0.442, 0.0, 0.0, 0.0,
        0.0, 0.242, 0.758, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
    }

    if (activeSimulacion == 'Deuteranopia') {
      return const [
        0.625, 0.375, 0.0, 0.0, 0.0,
        0.7, 0.3, 0.0, 0.0, 0.0,
        0.0, 0.3, 0.7, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
    }

    return const [
      0.95, 0.05, 0.0, 0.0, 0.0,
      0.0, 0.433, 0.567, 0.0, 0.0,
      0.0, 0.475, 0.525, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final datosNivel = controller.datosNivel;
    final user = UserController().currentUser;

    final Widget mainContent = Scaffold(
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFE2B755),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Text(
                          'DALTONISMO - Nivel: ${widget.nivelInicial}',
                          style: const TextStyle(
                            color: Color(0xFFE2B755),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${user.lives}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.diamond,
                        color: Colors.tealAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${user.pigments}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/imagenes/ficha.png',
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DALTONISMO',
                                style: TextStyle(
                                  color: Color(0xFF3B2312),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                datosNivel.instruction,
                                style: const TextStyle(
                                  color: Color(0xFF2C1A04),
                                  fontSize: 11,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'FILTRO DE SIMULACIÓN DE ACCESIBILIDAD:',
                          style: TextStyle(
                            color: Color(0xFFE2B755),
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterButton('REAL', 'Ninguno'),
                              const SizedBox(width: 6),
                              _buildFilterButton(
                                'PROTANOPIA',
                                'Protanopia',
                              ),
                              const SizedBox(width: 6),
                              _buildFilterButton(
                                'DEUTERANOPIA',
                                'Deuteranopia',
                              ),
                              const SizedBox(width: 6),
                              _buildFilterButton(
                                'TRITANOPIA',
                                'Tritanopia',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Alterna entre filtros para simular diferentes tipos de daltonismo o pulsa 'REAL' para contrastar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPorthole(
                              label: 'COLOR OBJETIVO',
                              child: Container(
                                color: datosNivel.targetColor,
                                child: const Icon(
                                  Icons.palette,
                                  color: Colors.black38,
                                  size: 28,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: Color(0xFFE2B755),
                                size: 30,
                              ),
                            ),
                            _buildPorthole(
                              label: controller.colorSeleccionado == null
                                  ? 'SIN SELECCIÓN'
                                  : 'TU SELECCIÓN',
                              child: controller.colorSeleccionado == null
                                  ? Container(
                                      color: Colors.black45,
                                      child: const Icon(
                                        Icons.help_outline,
                                        color: Colors.white24,
                                        size: 28,
                                      ),
                                    )
                                  : Container(
                                      color: controller.colorSeleccionado,
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.black38,
                                        size: 28,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AspectRatio(
                          aspectRatio: 2.1,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/imagenes/opcion.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 28,
                                    right: 28,
                                    top: 48,
                                    bottom: 26,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: datosNivel.options
                                        .take(4)
                                        .map((color) {
                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: _buildColorOption(color),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: controller.colorSeleccionado != null
                              ? _evaluarRespuesta
                              : null,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: controller.colorSeleccionado != null
                                ? 1
                                : 0.6,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: controller.colorSeleccionado != null
                                      ? const [
                                          Color(0xFFFBE49D),
                                          Color(0xFFC89218),
                                        ]
                                      : const [
                                          Color(0xFF8A7550),
                                          Color(0xFF4A3E2A),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: controller.colorSeleccionado != null
                                      ? const Color(0xFFFFF0B3)
                                      : const Color(0xFF5A4A30),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'COMPROBAR',
                                  style: TextStyle(
                                    color: controller.colorSeleccionado != null
                                        ? const Color(0xFF2C1A04)
                                        : Colors.white38,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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

    if (activeSimulacion == 'Ninguno') {
      return mainContent;
    }

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_getColorMatrix()),
      child: mainContent,
    );
  }
}
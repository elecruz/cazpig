import 'package:flutter/material.dart';

import '../../../controllers/level_generator.dart';
import '../../../controllers/nivel8_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/level_model.dart';
import '../../widgets/game_bottom_sheet.dart';

class Nivel8Screen extends StatefulWidget {
  final int nivelInicial;

  const Nivel8Screen({
    super.key,
    required this.nivelInicial,
  });

  @override
  State<Nivel8Screen> createState() => _Nivel8ScreenState();
}

class _Nivel8ScreenState extends State<Nivel8Screen> {
  late final Nivel8Controller controller =
      Nivel8Controller(nivelInicial: widget.nivelInicial);

  static const Color dorado = Color(0xFFFFD580);
  static const Color textoClaro = Color(0xFFFFE4A3);
  static const Color madera = Color(0xFF4A2818);

  final List<String> _imagenesCalidas = [
    'assets/imagenes/lingote_amarillo.png',
    'assets/imagenes/lingote_naranja.png',
  ];

  final List<String> _imagenesFrias = [
    'assets/imagenes/polvo_azul.png',
    'assets/imagenes/polvo_turquesa.png',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _esCalido(Color color) {
    return controller.datosNivel.warmColors.any(
      (item) => item.value == color.value,
    );
  }

  String _imagenDelPigmento(Color color) {
    final bool esCalido = _esCalido(color);

    final List<Color> colores = esCalido
        ? controller.datosNivel.warmColors
        : controller.datosNivel.coldColors;

    final List<String> imagenes =
        esCalido ? _imagenesCalidas : _imagenesFrias;

    final int index = colores.indexWhere(
      (item) => item.value == color.value,
    );

    if (index >= 0 && index < imagenes.length) {
      return imagenes[index];
    }

    return imagenes.first;
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
            : 'Algún pigmento está en la zona equivocada. ¡Inténtalo de nuevo!',
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
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
            icon: const Icon(
              Icons.arrow_back,
              color: dorado,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Text(
              'TEMPERATURA - Nivel ${widget.nivelInicial}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: dorado,
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
              color: dorado,
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
              color: dorado,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionPanel(TempLevelModel datos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        20,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/imagenes/ficha.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TEMPERATURA',
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

  Widget _buildSectionTitle() {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -18,
            right: -18,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/imagenes/tabla.png',
              fit: BoxFit.fill,
            ),
          ),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'BOTINES DE COLOR',
              style: TextStyle(
                color: textoClaro,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPigment({
    required Color color,
    required bool isFeedback,
    bool enSaco = false,
  }) {
    final bool esCalido = _esCalido(color);

    final double size = isFeedback
        ? 88
        : enSaco && !esCalido
            ? 82
            : 58;

    Widget imagen = Image.asset(
      _imagenDelPigmento(color),
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
        child: esCalido || !enSaco
            ? Center(
                child: imagen,
              )
            : imagen,
      ),
    );
  }

  Widget _buildAvailablePigments() {
    final List<Color> allColors =
        List<Color>.from(controller.datosNivel.allOptions);

    return SizedBox(
      width: double.infinity,
      height: 142,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/imagenes/cofres.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: allColors.map((color) {
                final bool disponible = controller.available.any(
                  (item) => item.value == color.value,
                );

                return SizedBox(
                  width: 78,
                  height: 88,
                  child: disponible
                      ? LongPressDraggable<Color>(
                          data: color,
                          feedback: _buildPigment(
                            color: color,
                            isFeedback: true,
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.18,
                            child: _buildPigment(
                              color: color,
                              isFeedback: false,
                              enSaco: true,
                            ),
                          ),
                          child: _buildPigment(
                            color: color,
                            isFeedback: false,
                            enSaco: true,
                          ),
                        )
                      : const SizedBox.expand(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDropMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0x66FFE4A3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0x99552E16),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'ARRASTRA\nAQUÍ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: madera,
            fontSize: 17,
            height: 1.05,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Color(0xFFFFE4A3),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone({
    required String zone,
    required List<Color> colors,
    required Color borderColor,
  }) {
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
            height: 330,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: isOver
                  ? Border.all(
                      color: Colors.white,
                      width: 3,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 7,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Transform.translate(
                    offset: const Offset(0, -8),
                    child: Image.asset(
                      zonaCalida
                          ? 'assets/imagenes/cajasol.png'
                          : 'assets/imagenes/cajafria.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  top: 78,
                  bottom: 22,
                  child: colors.isEmpty
                      ? _buildEmptyDropMessage()
                      : GridView.builder(
                          padding: const EdgeInsets.all(6),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            final Color color = colors[index];

                            return GestureDetector(
                              onTap: () {
                                controller.classifyColor(
                                  color,
                                  'available',
                                );
                              },
                              child: _buildPigment(
                                color: color,
                                isFeedback: false,
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

  Widget _buildDropZones() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropZone(
              zone: 'warm',
              colors: controller.warm,
              borderColor: const Color(0xFFD77A3B),
            ),
            const SizedBox(width: 12),
            _buildDropZone(
              zone: 'cold',
              colors: controller.cold,
              borderColor: const Color(0xFF73B8D8),
            ),
          ],
        ),
        if (controller.available.isEmpty)
          const Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '¡TODOS CLASIFICADOS!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE4A3),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMastButton() {
    return SizedBox(
      width: double.infinity,
      height: 145,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/imagenes/mastil.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 48,
            right: 48,
            top: 46,
            bottom: 42,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.listoParaComprobar
                    ? _comprobar
                    : null,
                borderRadius: BorderRadius.circular(18),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'COMPROBAR',
                      style: TextStyle(
                        color: controller.listoParaComprobar
                            ? const Color(0xFFFFE6A5)
                            : Colors.white38,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        shadows: const [
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final TempLevelModel datos = controller.datosNivel;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/imagenes/fondobarco.png',
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
                          8,
                        ),
                        child: Column(
                          children: [
                            _buildInstructionPanel(datos),
                            const SizedBox(height: 14),
                            _buildSectionTitle(),
                            const SizedBox(height: 10),
                            _buildAvailablePigments(),
                            const SizedBox(height: 18),
                            _buildDropZones(),
                            const SizedBox(height: 12),
                            _buildMastButton(),
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
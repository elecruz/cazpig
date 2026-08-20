import 'package:flutter/material.dart';
import 'dart:math';

import '../../controllers/user_controller.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/floating_tooltip.dart';
import '../widgets/path_painter.dart';
import '../widgets/nivel_helpers.dart';
import '../widgets/game_dialogs.dart';
import '../widgets/seal_node_widget.dart';


import 'gameplay/nivel1_screen.dart';
import 'gameplay/nivel2_screen.dart';
import 'gameplay/nivel3_screen.dart';
import 'gameplay/nivel4_screen.dart';
import 'gameplay/nivel5_screen.dart';
import 'gameplay/nivel6_screen.dart';
import 'gameplay/nivel7_screen.dart';
import 'gameplay/nivel8_screen.dart';
import 'gameplay/nivel9_screen.dart';
import 'gameplay/nivel10_screen.dart';
import 'gameplay/nivel11_screen.dart';
import 'gameplay/nivel12_screen.dart';

// ─── Constantes globales de layout ──────────────────────────────────────────

class NivelSeleccionScreen extends StatefulWidget {
  const NivelSeleccionScreen({super.key});

  @override
  State<NivelSeleccionScreen> createState() => _NivelSeleccionScreenState();
}

class _NivelSeleccionScreenState extends State<NivelSeleccionScreen>
    with SingleTickerProviderStateMixin {
  final UserController _userController = UserController();
  late ScrollController _scrollController;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    final int active = _userController.currentUser.currentLevelReached;
    final int activeRow = getRowForLevel(active);
    final double initialOffset =
        max(0.0, kHeaderHeight + (activeRow - 3) * kRowHeight);
    _scrollController = ScrollController(initialScrollOffset: initialOffset);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

void _iniciarDesafioDeNivel(int nivel) {
    if (_userController.currentUser.lives <= 0) {
      GameDialogs.mostrarCompraVidas(context, _userController);
      return;
    }
    Widget pantalla;
    final int tipo = nivel % 12;
    switch (tipo) {
      case 1:  pantalla = Nivel1Screen(nivelInicial: nivel);  break;
      case 2:  pantalla = Nivel2Screen(nivelInicial: nivel);  break;
      case 3:  pantalla = Nivel3Screen(nivelInicial: nivel);  break;
      case 4:  pantalla = Nivel4Screen(nivelInicial: nivel);  break;
      case 5:  pantalla = Nivel5Screen(nivelInicial: nivel);  break;
      case 6:  pantalla = Nivel6Screen(nivelInicial: nivel);  break;
      case 7:  pantalla = Nivel7Screen(nivelInicial: nivel);  break;
      case 8:  pantalla = Nivel8Screen(nivelInicial: nivel);  break;
      case 9:  pantalla = Nivel9Screen(nivelInicial: nivel);  break;
      case 10: pantalla = Nivel10Screen(nivelInicial: nivel); break;
      case 11: pantalla = Nivel11Screen(nivelInicial: nivel); break;
      default: pantalla = Nivel12Screen(nivelInicial: nivel); break;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    ).then((_) => _userController.verificarYRegenerarVidas());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _userController,
      builder: (context, _) {
        final int currentLevel =
            _userController.currentUser.currentLevelReached;
        final int totalRows = getTotalRows(kTotalLevels);

        return Stack(
          children: [
            // ── 1. Fondo pergamino (Completo de borde a borde) ──────────────
            Positioned.fill(
              child: Image.asset(
                'assets/imagenes/fondo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2B1A0A).withOpacity(0.50),
                      const Color(0xFF1A1000).withOpacity(0.30),
                      const Color(0xFF2B1A0A).withOpacity(0.55),
                    ],
                  ),
                ),
              ),
            ),

            // ── 2. Scaffold con el mapa protegido por SafeArea ──────────────
            Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,
              bottomNavigationBar: AppNavigationBar(
                currentIndex: 1,
                onTap: (_) {},
              ),
              // El SafeArea envuelve el body completo para proteger la zona superior e inferior
              body: SafeArea(
                top: true,
                bottom: true,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double sw = constraints.maxWidth;
                    // Se añade un margen extra abajo para que la barra de navegación no pise los últimos niveles
                    final double totalH =
                        kHeaderHeight + (totalRows + 1) * kRowHeight + 220;

                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: SizedBox(
                        width: sw,
                        height: totalH,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // ── Camino sinuoso punteado ──
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PathPainter(
                                  screenWidth: sw,
                                  currentLevel: currentLevel,
                                  totalRows: totalRows,
                                  headerHeight: kHeaderHeight,
                                  rowHeight: kRowHeight,
                                  getNodeY: getNodeY,
                                ),
                              ),
                            ),

                            // ── Header de sección ──
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: _buildSectionHeader(),
                            ),

                            // ── Nodos de nivel ──
                            for (int lvl = 1; lvl <= kTotalLevels; lvl++)
                              SealNodeWidget(
                                  level: lvl,
                                   currentLevel: currentLevel,
                                   screenWidth: sw,
                                   pulseCtrl: _pulseCtrl,
                                   onTap: lvl % 5 == 0
                                       ? () => GameDialogs.abrirCofre(
                                            context,
                                             lvl,
                                               _userController,
                                             )
                                         : () => _iniciarDesafioDeNivel(lvl), // <--- AQUÍ SE LLAMA
                                          ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Header de sección ──────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Container(
      // Reducido el margen superior de 52 a 12 porque el SafeArea ya añade la separación del notch
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2B1A).withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD4A017).withOpacity(0.72),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A017).withOpacity(0.28),
            blurRadius: 22,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFD4A017).withOpacity(0.58)),
                  ),
                  child: const Text(
                    "⚓  MAPA · RUTA 1",
                    style: TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Ruta de los Pigmentos",
                  style: TextStyle(
                    color: Color(0xFFF5E6C8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Supera mezclas, branding y degradados para coronarte maestro.",
                  style: TextStyle(
                    color: const Color(0xFFD4B896).withOpacity(0.88),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFFD4A017),
                  BlendMode.modulate,
                ),
                child: Image.asset(
                  'assets/imagenes/sello.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
              const Icon(Icons.explore_rounded,
                  color: Colors.white, size: 26),
            ],
          ),
        ],
      ),
    );
  }
    }

  
import 'package:flutter/material.dart';
import '../models/level_model.dart';
import 'base_level_controller.dart';
import 'level_generator.dart';

class Nivel6Controller extends BaseLevelController<BlindLevelModel> {
  Color? colorSeleccionado;

  Nivel6Controller({required super.nivelInicial}) {
    datosNivel = LevelGenerator.generarNivel(nivelInicial) as BlindLevelModel;
  }

  void seleccionarColor(Color color) {
    if (comprobado) return;
    colorSeleccionado = color;
    notifyListeners();
  }

  @override
  bool get listoParaComprobar => colorSeleccionado != null;

  @override
  bool comprobarResultado() {
    if (colorSeleccionado == null) return false;
    comprobado = true;
    notifyListeners();
    return colorSeleccionado!.value == datosNivel.correctColor.value;
  }

  @override
  void reiniciarSeleccion() {
    colorSeleccionado = null;
    comprobado = false;
    notifyListeners();
  }

  // Matrices de color para filtros de Daltonismo (formato 4x5 de Flutter)
  List<double> get matrixFilter {
    if (datosNivel.blindType == "Protanopia") {
      return const [
        0.567, 0.433, 0.0,   0.0, 0.0,
        0.558, 0.442, 0.0,   0.0, 0.0,
        0.0,   0.242, 0.758, 0.0, 0.0,
        0.0,   0.0,   0.0,   1.0, 0.0,
      ];
    } else if (datosNivel.blindType == "Deuteranopia") {
      return const [
        0.625, 0.375, 0.0,   0.0, 0.0,
        0.7,   0.3,   0.0,   0.0, 0.0,
        0.0,   0.3,   0.7,   0.0, 0.0,
        0.0,   0.0,   0.0,   1.0, 0.0,
      ];
    } else {
      // Tritanopia (blue blindness)
      return const [
        0.95,  0.05,  0.0,   0.0, 0.0,
        0.0,   0.433, 0.567, 0.0, 0.0,
        0.0,   0.475, 0.525, 0.0, 0.0,
        0.0,   0.0,   0.0,   1.0, 0.0,
      ];
    }
  }

  // Método de simulación de color bajo filtro de daltonismo
  Color simularFiltro(Color c, String tipo) {
    final List<double> m = (tipo == "Protanopia")
        ? const [0.567, 0.433, 0.0, 0.558, 0.442, 0.0, 0.0, 0.242, 0.758]
        : (tipo == "Deuteranopia")
            ? const [0.625, 0.375, 0.0, 0.7, 0.3, 0.0, 0.0, 0.3, 0.7]
            : const [0.95, 0.05, 0.0, 0.0, 0.433, 0.567, 0.0, 0.475, 0.525];

    final double r = (c.r * 255.0 * m[0] + c.g * 255.0 * m[1] + c.b * 255.0 * m[2]).clamp(0.0, 255.0);
    final double g = (c.r * 255.0 * m[3] + c.g * 255.0 * m[4] + c.b * 255.0 * m[5]).clamp(0.0, 255.0);
    final double b = (c.r * 255.0 * m[6] + c.g * 255.0 * m[7] + c.b * 255.0 * m[8]).clamp(0.0, 255.0);

    return Color.fromARGB((c.a * 255).round(), r.round(), g.round(), b.round());
  }
}

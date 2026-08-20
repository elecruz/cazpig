import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final double screenWidth;
  final int currentLevel;
  final int totalRows;
  final double headerHeight;
  final double rowHeight;
  final double Function(int level) getNodeY;

  PathPainter({
    required this.screenWidth,
    required this.currentLevel,
    required this.totalRows,
    required this.headerHeight,
    required this.rowHeight,
    required this.getNodeY,
  });

  double _strandX(int row, bool isLeft, double width) {
    final double center = width * 0.5;
    final double amp = width * 0.28;
    if (row % 2 == 1) {
      return center;
    } else {
      return isLeft ? (center - amp) : (center + amp);
    }
  }

  double _rowY(int row) => headerHeight + (row - 0.5) * rowHeight;

  @override
  void paint(Canvas canvas, Size size) {
    _drawStrand(canvas, isLeft: true);
    _drawStrand(canvas, isLeft: false);
  }

  void _drawStrand(Canvas canvas, {required bool isLeft}) {
    final Path path = Path();
    path.moveTo(_strandX(1, isLeft, screenWidth), _rowY(1));

    for (int r = 1; r < totalRows; r++) {
      final double x1 = _strandX(r, isLeft, screenWidth);
      final double y1 = _rowY(r);
      final double x2 = _strandX(r + 1, isLeft, screenWidth);
      final double y2 = _rowY(r + 1);
      final double midY = (y1 + y2) / 2;

      path.cubicTo(x1, midY, x2, midY, x2, y2);
    }

    // Fondo sombra
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Línea base oscura
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2C251C).withOpacity(0.4)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    _drawDotsOnPath(canvas, path, isLeft);
  }

  void _drawDotsOnPath(Canvas canvas, Path path, bool isLeft) {
    const double dotR = 4.2;
    const double spacing = 16.0;
    double distance = spacing / 2;

    // Altura del nivel actual y de la fila anterior
    final double currentYLimit = getNodeY(currentLevel);
    final double previousRowYLimit = currentYLimit - rowHeight;

    // Nivel 2, 5, 8... es izquierda (rem == 2)
    // Nivel 3, 6, 9... es derecha (rem == 0)
    // Nivel 1, 4, 7... es centro (rem == 1)
    final int rem = currentLevel % 3;

    for (final ui.PathMetric m in path.computeMetrics()) {
      while (distance < m.length) {
        final ui.Tangent? t = m.getTangentForOffset(distance);
        if (t != null) {
          bool unlocked = false;

          if (t.position.dy <= previousRowYLimit + 10) {
            // Filas anteriores completadas: se iluminan ambas
            unlocked = true;
          } else if (t.position.dy <= currentYLimit + 10) {
            // Tramo hacia la fila actual: solo se ilumina la hebra correspondiente
            if (rem == 1) {
              unlocked = true; // Centro (conecta todo)
            } else if (rem == 2 && isLeft) {
              unlocked = true; // Solo hebra izquierda (Nivel 2, 5, etc.)
            } else if (rem == 0 && (isLeft || !isLeft)) {
              // Si llegó al nivel de la derecha (Nivel 3, 6), el de la izquierda ya se completó
              unlocked = true;
            }
          }

          final Color dotColor = unlocked
              ? const Color(0xFFD4A017)
              : const Color(0xFF3E485A);

          canvas.drawCircle(
            t.position + const Offset(0, 1.5),
            dotR,
            Paint()
              ..color = Colors.black.withOpacity(0.35)
              ..style = PaintingStyle.fill,
          );
          canvas.drawCircle(
            t.position,
            dotR,
            Paint()
              ..color = dotColor
              ..style = PaintingStyle.fill,
          );
        }
        distance += spacing;
      }
      distance = spacing / 2;
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) =>
      oldDelegate.currentLevel != currentLevel ||
      oldDelegate.screenWidth != screenWidth;
}
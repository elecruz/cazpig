import 'package:flutter/material.dart';

/// Botón selector de simulación de filtro de daltonismo
class FiltroDaltonismoButton extends StatelessWidget {
  final String label;
  final String value;
  final bool activo;
  final VoidCallback onTap;

  const FiltroDaltonismoButton({
    super.key,
    required this.label,
    required this.value,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: activo
                ? const [Color(0xFFFBE49D), Color(0xFFC89218)]
                : const [Color(0xFFC3A26B), Color(0xFF7A5A28)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo ? const Color(0xFFFFF7C2) : const Color(0xFF4A3410),
            width: activo ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: activo ? const Color(0xFF2C1A04) : const Color(0xFF1E1102),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

/// Ojo espectral con lente circular para simular visión daltonizada
class VisualizadorOjoWidget extends StatelessWidget {
  final Widget child;
  final String label;

  const VisualizadorOjoWidget({
    super.key,
    required this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Ficha de opción de color para Nivel 6
class OpcionPigmentoCardWidget extends StatelessWidget {
  final Color color;
  final String nombre;
  final bool seleccionado;
  final VoidCallback onTap;

  const OpcionPigmentoCardWidget({
    super.key,
    required this.color,
    required this.nombre,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
            bottom: Radius.circular(14),
          ),
          border: Border.all(
            color: seleccionado ? const Color(0xFFFFD700) : Colors.black.withOpacity(0.3),
            width: seleccionado ? 2.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: seleccionado ? color.withOpacity(0.5) : Colors.black.withOpacity(0.3),
              blurRadius: seleccionado ? 8 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18),
            bottom: Radius.circular(12),
          ),
          child: Container(
            color: color,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        nombre.replaceAll('\n', ' '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 7,
                        fontFamily: 'monospace',
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
}

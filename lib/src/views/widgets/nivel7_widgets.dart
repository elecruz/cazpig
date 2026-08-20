import 'package:flutter/material.dart';

/// Portal circular para visualizar la muestra de color objetivo o mezcla
class PortalColorWidget extends StatelessWidget {
  final Color color;
  final String title;
  final String hex;

  const PortalColorWidget({
    super.key,
    required this.color,
    required this.title,
    required this.hex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.7),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 1.8,
                  child: Image.asset(
                    'assets/imagenes/rueda.png',
                    width: 140,
                    height: 140,
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
              color: Color(0xFFFFD580),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hex,
            style: const TextStyle(
              color: Color(0xFFFFE4A3),
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Control deslizante estilizado de cañón RGB (Canal R, G o B)
class CanalRgbSliderWidget extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const CanalRgbSliderWidget({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label [${value.toInt()}]',
                style: const TextStyle(
                  color: Color(0xFFFFD580),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '#${value.toInt().toRadixString(16).padLeft(2, '0').toUpperCase()}',
                style: const TextStyle(
                  color: Color(0xFFFFE4A3),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 95,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/imagenes/cañon.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    left: width * 0.38,
                    right: width * 0.03,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12,
                        activeTrackColor: color.withOpacity(0.9),
                        inactiveTrackColor: const Color(0xFF3A2015),
                        thumbColor: color,
                        overlayColor: color.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
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
}

/// Medidor de similitud cromática con brújula
class MedidorSimilitudWidget extends StatelessWidget {
  final double similarity;
  final String feedbackMessage;

  const MedidorSimilitudWidget({
    super.key,
    required this.similarity,
    required this.feedbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double panelWidth = constraints.maxWidth;
        final double imageWidth = panelWidth * 1.7;
        final double imageHeight = imageWidth * 256 / 960;

        return SizedBox(
          width: double.infinity,
          height: 150,
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
                left: 36,
                right: 36,
                top: 70,
                bottom: 14,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        feedbackMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFE4A3),
                          fontSize: 12,
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
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'floating_tooltip.dart';
import 'nivel_helpers.dart';

class SealNodeWidget extends StatelessWidget {
  final int level;
  final int currentLevel;
  final double screenWidth;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;

  const SealNodeWidget({
    super.key,
    required this.level,
    required this.currentLevel,
    required this.screenWidth,
    required this.pulseCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = level < currentLevel;
    final bool isActive = level == currentLevel;
    final bool isLocked = level > currentLevel;
    final bool isChest = level % 5 == 0;

    Color sealColor;
    if (isLocked) {
      sealColor = const Color(0xFF4A5268);
    } else if (isChest) {
      sealColor = const Color(0xFFD4A017);
    } else if (isCompleted) {
      const shades = [
        Color(0xFF7B5E3A),
        Color(0xFF3A7B6F),
        Color(0xFF7B3A4F),
        Color(0xFF3A4F7B),
      ];
      sealColor = shades[level % shades.length];
    } else {
      sealColor = const Color(0xFFC8860A);
    }

    Widget sealContent;
    if (isChest) {
      sealContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.drafts_outlined : Icons.inventory_2_outlined,
            color: isLocked ? Colors.white38 : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            '$level',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isLocked ? Colors.white38 : Colors.white,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      );
    } else {
      sealContent = Text(
        '$level',
        style: TextStyle(
          fontSize: level >= 100 ? 26 : 32,
          fontWeight: FontWeight.w900,
          color: isLocked ? Colors.white38 : Colors.white,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
      );
    }

    Widget sealWidget = Stack(
      alignment: Alignment.center,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(sealColor, BlendMode.modulate),
          child: Image.asset(
            'assets/imagenes/sello.png',
            width: kSealSize,
            height: kSealSize,
            fit: BoxFit.contain,
          ),
        ),
        sealContent,
      ],
    );

    if (isActive) {
      sealWidget = AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withOpacity(0.5 + pulseCtrl.value * 0.3),
                blurRadius: 18 + pulseCtrl.value * 20,
                spreadRadius: 4 + pulseCtrl.value * 10,
              ),
            ],
          ),
          child: child,
        ),
        child: sealWidget,
      );
    }

    final double cx = getNodeX(level, screenWidth);
    final double cy = getNodeY(level);
    const double half = kSealSize / 2;
    final double rotationAngle = sin(level * 1.5) * 0.15;

    return Stack(
      children: [
        if (isActive)
          Positioned(
            left: cx - 55,
            top: cy - half - 48,
            width: 110,
            child: const FloatingTooltip(),
          ),
        Positioned(
          left: cx - half,
          top: cy - half,
          width: kSealSize,
          height: kSealSize,
          child: Transform.rotate(
            angle: rotationAngle,
            child: GestureDetector(
              onTap: isLocked ? null : onTap,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 3,
                    left: 2,
                    child: Opacity(
                      opacity: 0.25,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                        child: Image.asset(
                          'assets/imagenes/sello.png',
                          width: kSealSize,
                          height: kSealSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  sealWidget,
                  if (isCompleted && !isChest)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D00),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF5E6C8), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(Icons.check, size: 13, color: Colors.white),
                      ),
                    ),
                  if (isLocked)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3545),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: const Icon(Icons.lock, size: 11, color: Colors.white38),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isChest)
          Positioned(
            left: cx - 28,
            top: cy + half + 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: isCompleted
                        ? const Color(0xFFD4A017)
                        : const Color(0xFF6B5A45).withOpacity(0.55),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
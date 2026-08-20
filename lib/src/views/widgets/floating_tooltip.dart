import 'package:flutter/material.dart';

class FloatingTooltip extends StatefulWidget {
  const FloatingTooltip({super.key});

  @override
  State<FloatingTooltip> createState() => _FloatingTooltipState();
}

class _FloatingTooltipState extends State<FloatingTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _bounce.value), child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD166),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              "¡JUGAR!",
              style: TextStyle(
                color: Color(0xFF3D2200),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          CustomPaint(
            size: const Size(14, 7),
            painter: _TrianglePainter(),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()
        ..color = const Color(0xFFFFD166)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => false;
}
import 'package:flutter/material.dart';

class CustomCheckButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool habilitado;
  final String texto;

  const CustomCheckButton({
    super.key,
    required this.onPressed,
    this.habilitado = true,
    this.texto = 'COMPROBAR',
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: habilitado ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: habilitado ? onPressed : null,
        child: SizedBox(
          width: 320,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/imagenes/cofre.png',
                  fit: BoxFit.contain,
                ),
              ),
              // Centrado vertical compensado hacia el área verde
              Positioned(
                top: 50,
                child: Text(
                  texto,
                  style: const TextStyle(
                    color: Color(0xFFFFF1C2),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                      Shadow(
                        color: Color(0xFF1E3A0F),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
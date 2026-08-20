import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';

class GameDialogs {
  static void mostrarCompraVidas(BuildContext context, UserController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1A1000),
        title: const Text(
          "❤️ Sin Vidas",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, color: Color(0xFFFF4B4B), size: 70),
            SizedBox(height: 16),
            Text(
              "No tienes vidas suficientes para jugar.\n¿Quieres reponer tus 5 vidas de inmediato?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              "Coste: 150 💎",
              style: TextStyle(
                color: Color(0xFF1CB0F6),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              bool ok = controller.comprarVidasConPigmentos();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  ok ? "¡Vidas recargadas al máximo!" : "No tienes suficientes pigmentos 💎",
                ),
                backgroundColor: ok ? Colors.green : Colors.red,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B4B),
            ),
            child: const Text(
              "Comprar",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static void abrirCofre(BuildContext context, int nivel, UserController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1E2638),
        title: const Text(
          "🎁 Cofre de Recompensa",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFFD166),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.redeem_rounded, color: Color(0xFFFFD166), size: 80),
            const SizedBox(height: 16),
            const Text(
              "¡Has alcanzado y abierto un cofre en tu camino cromático!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "+150 XP y +50 Pigmentos",
                style: TextStyle(
                  color: Color(0xFF00C897),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                controller.completarNivel(nivel);
                Navigator.pop(context);
              },
              child: const Text(
                "¡Recibir Recompensa!",
                style: TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
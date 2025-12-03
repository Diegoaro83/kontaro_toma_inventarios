import 'package:flutter/material.dart';
import 'dart:ui';

/// 📱 BARRA INFERIOR DE MÓDULO REUTILIZABLE
///
/// Widget para la barra inferior con botones de navegación:
/// - Botón "Volver" para regresar al selector de módulos
/// - Botón "Salir" para cerrar sesión
/// - Fondo y estilo coherente con la app
/// 📱 BARRA INFERIOR DE MÓDULO UNIFICADA
///
/// Muestra el estado del sistema, última sincronización y los botones Volver/Salir en una sola barra.
class BarraInferiorModulo extends StatelessWidget {
  final String estadoSistema; // Texto del estado del sistema
  final String ultimaSincronizacion; // Texto de última sincronización
  final VoidCallback onVolver; // Acción al presionar "Volver"
  final VoidCallback onSalir; // Acción al presionar "Salir"

  const BarraInferiorModulo({
    Key? key,
    required this.estadoSistema,
    required this.ultimaSincronizacion,
    required this.onVolver,
    required this.onSalir,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xE61A1F3A), // #1A1F3A 90%
            Color(0xE62D1B4E), // #2D1B4E 90%
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(color: Color.fromARGB(255, 84, 94, 116), width: 2),
        ),
      ),
      child: Row(
        children: [
          // Estado del sistema + sincronización
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AnimatedPingDot(), // 🟢 Indicador animado de sistema activo
                    const SizedBox(width: 8),
                    Text(
                      estadoSistema,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Última sincronización: $ultimaSincronizacion',
                  style: const TextStyle(
                    color: Color(0xFF64748b),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Botones Volver y Salir
          ElevatedButton.icon(
            onPressed: onVolver,
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Volver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0x403B7FFF,
              ), // Azul más translúcido (25% opacidad)
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.white24, width: 1.2),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onSalir,
            icon: const Icon(Icons.exit_to_app, size: 20),
            label: const Text('Salir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0x40EA4747,
              ), // Rojo más translúcido (25% opacidad)
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.white24, width: 1.2),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// Indicador pulsante animado tipo glassmorphism
class _AnimatedPingDot extends StatefulWidget {
  @override
  State<_AnimatedPingDot> createState() => _AnimatedPingDotState();
}

class _AnimatedPingDotState extends State<_AnimatedPingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 0.0).animate(_controller),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 2.2).animate(_controller),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0x3300FF88),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF00FF88),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 🎨 CARD GENERAL DE MÓDULO (ESTILO PROFESIONAL)
/// Card con fondo oscuro, borde con gradiente, ícono grande a la izquierda,
/// título y subtítulo alineados, flecha a la derecha y espaciado generoso.
class ModuloCardGeneral extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const ModuloCardGeneral({
    super.key,
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Gradiente para el borde usando CustomPainter
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF181A2F), // Fondo azul oscuro
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          painter: _GradientBorderPainter(colorIcono: colorIcono),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorIcono.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(icono, color: colorIcono, size: 36),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        descripcion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB0B6C8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Icon(
                  Icons.arrow_right_alt_rounded,
                  color: colorIcono,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 PINTOR DE BORDE CON GRADIENTE
/// Dibuja un borde exterior con gradiente usando el color del módulo.
class _GradientBorderPainter extends CustomPainter {
  final Color colorIcono;
  _GradientBorderPainter({required this.colorIcono});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = 16.0;
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          colorIcono.withOpacity(0.7),
          colorIcono.withOpacity(0.25),
          colorIcono.withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final borderRect = RRect.fromRectAndRadius(
      rect.deflate(1.1),
      Radius.circular(r),
    );
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

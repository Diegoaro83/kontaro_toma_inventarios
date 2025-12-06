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
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181A2F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomPaint(
            painter: _GradientBorderPainter(colorIcono: colorIcono),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorIcono.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icono, color: colorIcono, size: 20),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13, // texto del título más pequeño
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

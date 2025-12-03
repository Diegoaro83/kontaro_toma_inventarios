import '../../widgets/common/barra_superior_modulo.dart';
import 'package:flutter/material.dart';
import 'modulo_base.dart';
import '../../widgets/common/barra_inferior_modulo.dart';

/// 🕵️ MÓDULO AUDITOR
///
/// Pantalla personalizada para el rol Auditor.
/// - Acceso solo a inventarios, cíclicos y referencias
/// - Botón de regreso al selector de módulos
class ModuloAuditor extends StatelessWidget {
  const ModuloAuditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 📱 Layout responsive: muestra los cards en fila si hay espacio, en columna si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // 🎨 Cards de módulos del auditor
    final auditorCards = [
      _buildAuditorCard(
        icon: Icons.qr_code_scanner,
        colorIcon: const Color(0xFF06B6D4),
        titulo: 'Inventarios',
        descripcion: 'Toma de inventario y escaneo',
        colorTexto: const Color(0xFF06B6D4),
      ),
      _buildAuditorCard(
        icon: Icons.loop,
        colorIcon: const Color(0xFF06B6D4),
        titulo: 'Inventarios Cíclicos',
        descripcion:
            'Carga de Excel, selección manual o aleatoria de referencias a contar',
        colorTexto: const Color(0xFF06B6D4),
      ),
      _buildAuditorCard(
        icon: Icons.search,
        colorIcon: const Color(0xFFF59E0B),
        titulo: 'Consultas de Referencias',
        descripcion:
            'Consulta de códigos de barras, cantidades, valores y metas en tiempo real',
        colorTexto: const Color(0xFFF59E0B),
      ),
    ];

    return ModuloBaseScreen(
      tituloModulo: 'Selecciona un módulo',
      barraSuperior: BarraSuperiorModulo(
        nombreEmpresa: 'Oxígeno Zero',
        subtitulo: 'Panel Auditor',
        nombreUsuario: 'Diego',
        nombrePerfil: 'Auditor',
        estadoSistema: 'Conectado',
      ),
      barraInferior: BarraInferiorModulo(
        estadoSistema: 'Conectado',
        ultimaSincronizacion: 'Hace 2 min',
        onVolver: () => Navigator.pop(context),
        onSalir: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
        // Ajuste: menos padding vertical para evitar error SnackBar
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ), // Menos vertical
        child: isMobile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...auditorCards.map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: card,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...auditorCards.map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: card,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 🎨 Construye un card de módulo para el auditor
  /// - icon: Ícono principal del card
  /// - colorIcon: Color del ícono
  /// - titulo: Título del módulo
  /// - descripcion: Descripción breve
  /// - colorTexto: Color del texto de acción
  Widget _buildAuditorCard({
    required IconData icon,
    required Color colorIcon,
    required String titulo,
    required String descripcion,
    required Color colorTexto,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorIcon, size: 40),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(descripcion),
            const SizedBox(height: 12),
            Text(
              'Abrir módulo →',
              style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

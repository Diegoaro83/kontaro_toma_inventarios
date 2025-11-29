import 'package:flutter/material.dart';
import 'dart:convert';
import '../theme/app_colors.dart';

/// 👕 WIDGET DE PANEL DE TALLAS
///
/// Muestra las tallas disponibles vs tallas escaneadas de una referencia.
/// Permite visualizar qué tallas faltan encontrar durante el inventario.

class PanelTallasWidget extends StatelessWidget {
  final String? tallasDisponiblesJson; // JSON: ["S","M","L","XL"]
  final String? tallasEscaneadasJson; // JSON: ["S","M"]
  final String nombreReferencia;
  final String codigoReferencia;

  const PanelTallasWidget({
    super.key,
    this.tallasDisponiblesJson,
    this.tallasEscaneadasJson,
    required this.nombreReferencia,
    required this.codigoReferencia,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay tallas disponibles, no mostrar el panel
    if (tallasDisponiblesJson == null || tallasDisponiblesJson!.isEmpty) {
      return const SizedBox.shrink();
    }

    List<String> tallasDisponibles = [];
    List<String> tallasEscaneadas = [];

    try {
      tallasDisponibles = List<String>.from(
        json.decode(tallasDisponiblesJson!),
      );
      if (tallasEscaneadasJson != null && tallasEscaneadasJson!.isNotEmpty) {
        tallasEscaneadas = List<String>.from(
          json.decode(tallasEscaneadasJson!),
        );
      }
    } catch (e) {
      print('❌ Error al parsear JSON de tallas: $e');
      return const SizedBox.shrink();
    }

    // Calcular tallas faltantes
    final tallasFaltantes = tallasDisponibles
        .where((t) => !tallasEscaneadas.contains(t))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📋 Header
          Row(
            children: [
              Icon(Icons.checkroom, color: AppColors.inventoryGreen, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tallas Disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      codigoReferencia,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            nombreReferencia,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // 👕 Tallas iniciales (todas las disponibles)
          _buildSeccionTallas(
            titulo: 'Tallas Iniciales',
            tallas: tallasDisponibles,
            color: AppColors.textSecondary,
            icono: Icons.inventory_2,
          ),
          const SizedBox(height: 12),

          // ✅ Tallas escaneadas (encontradas)
          if (tallasEscaneadas.isNotEmpty)
            _buildSeccionTallas(
              titulo: 'Tallas Escaneadas',
              tallas: tallasEscaneadas,
              color: AppColors.success,
              icono: Icons.check_circle,
            ),
          if (tallasEscaneadas.isNotEmpty) const SizedBox(height: 12),

          // ⚠️ Tallas faltantes (aún no escaneadas)
          if (tallasFaltantes.isNotEmpty)
            _buildSeccionTallas(
              titulo: 'Tallas Faltantes',
              tallas: tallasFaltantes,
              color: AppColors.warning,
              icono: Icons.warning_amber,
              esFaltante: true,
            ),

          // 🎯 Indicador de progreso
          if (tallasDisponibles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildBarraProgreso(
              tallasEscaneadas.length,
              tallasDisponibles.length,
            ),
          ],
        ],
      ),
    );
  }

  /// 🎨 Construir sección de tallas
  Widget _buildSeccionTallas({
    required String titulo,
    required List<String> tallas,
    required Color color,
    required IconData icono,
    bool esFaltante = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${tallas.length})',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tallas
              .map((talla) => _buildChipTalla(talla, color, esFaltante))
              .toList(),
        ),
      ],
    );
  }

  /// 🏷️ Chip individual de talla
  Widget _buildChipTalla(String talla, Color color, bool esFaltante) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: esFaltante
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: esFaltante ? 0.5 : 0.3),
          width: esFaltante ? 2 : 1,
        ),
      ),
      child: Text(
        talla,
        style: TextStyle(
          fontSize: 13,
          fontWeight: esFaltante ? FontWeight.bold : FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// 📊 Barra de progreso de tallas
  Widget _buildBarraProgreso(int escaneadas, int totales) {
    final porcentaje = totales > 0 ? (escaneadas / totales) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de Tallas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$escaneadas / $totales (${porcentaje.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.inventoryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaje / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              porcentaje == 100 ? AppColors.success : AppColors.inventoryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

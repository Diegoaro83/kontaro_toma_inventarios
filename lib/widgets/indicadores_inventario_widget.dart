import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';

/// 📊 WIDGET DE INDICADORES DE INVENTARIO
///
/// Panel que muestra todos los indicadores en tiempo real durante el escaneo:
/// - Valores fijos (inicial)
/// - Valores dinámicos (escaneado, pendiente)
/// - Faltantes y sobrantes para auditoría

class IndicadoresInventarioWidget extends StatelessWidget {
  final Map<String, dynamic> indicadores;

  const IndicadoresInventarioWidget({super.key, required this.indicadores});

  @override
  Widget build(BuildContext context) {
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
          // 📋 Título
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.infoBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Indicadores de Inventario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 📊 Grid de indicadores
          _buildIndicadoresGrid(),
        ],
      ),
    );
  }

  /// 🎨 Construir grid de indicadores (2 columnas)
  Widget _buildIndicadoresGrid() {
    return Column(
      children: [
        // Fila 1: Valor Total vs Valor Escaneado
        Row(
          children: [
            Expanded(
              child: _buildIndicadorCard(
                titulo: 'Valor Total Inicial',
                valor: _formatMoneda(indicadores['valorTotalInicial'] ?? 0.0),
                icono: Icons.inventory_2,
                color: AppColors.textSecondary,
                esFijo: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIndicadorCard(
                titulo: 'Valor Escaneado',
                valor: _formatMoneda(indicadores['valorEscaneado'] ?? 0.0),
                icono: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Fila 2: Unidades Total vs Escaneadas
        Row(
          children: [
            Expanded(
              child: _buildIndicadorCard(
                titulo: 'Unidades Totales',
                valor: '${indicadores['cantidadUnidadesInicial'] ?? 0}',
                icono: Icons.shopping_bag,
                color: AppColors.textSecondary,
                esFijo: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIndicadorCard(
                titulo: 'Unidades Escaneadas',
                valor: '${indicadores['unidadesEscaneadas'] ?? 0}',
                icono: Icons.qr_code_scanner,
                color: AppColors.inventoryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Fila 3: Referencias completadas vs Pendientes
        Row(
          children: [
            Expanded(
              child: _buildIndicadorCard(
                titulo: 'Referencias',
                valor:
                    '${indicadores['referenciasCompletadas'] ?? 0} / ${indicadores['cantidadReferencias'] ?? 0}',
                icono: Icons.list_alt,
                color: AppColors.infoBlue,
                subtitulo:
                    '${(indicadores['porcentajeCompletado'] ?? 0.0).toStringAsFixed(1)}% completado',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildIndicadorCard(
                titulo: 'Pendientes',
                valor: '${indicadores['unidadesPendientes'] ?? 0}',
                icono: Icons.pending_actions,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sección de No Encontradas (si hay)
        if ((indicadores['unidadesNoEncontradas'] ?? 0) > 0) ...[
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          _buildSeccionNoEncontradas(),
          const SizedBox(height: 16),
        ],

        // Sección de Faltantes y Sobrantes
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 12),
        _buildSeccionAuditoria(),
      ],
    );
  }

  /// 🎯 Construir card individual de indicador
  Widget _buildIndicadorCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
    bool esFijo = false,
    String? subtitulo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (esFijo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'FIJO',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitulo,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  /// ⚠️ Sección de productos no encontrados
  Widget _buildSeccionNoEncontradas() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Productos No Encontrados en Inventario',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unidades: ${indicadores['unidadesNoEncontradas'] ?? 0}',
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              Text(
                'Valor: ${_formatMoneda(indicadores['valorNoEncontrado'] ?? 0.0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📈 Sección de auditoría (faltantes y sobrantes)
  Widget _buildSeccionAuditoria() {
    final faltantesUnidades = indicadores['faltantesUnidades'] ?? 0;
    final faltantesValor = indicadores['faltantesValor'] ?? 0.0;
    final sobrantesUnidades = indicadores['sobrantesUnidades'] ?? 0;
    final sobrantesValor = indicadores['sobrantesValor'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Auditoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAuditoriaCard(
                titulo: 'Faltantes',
                unidades: faltantesUnidades,
                valor: faltantesValor,
                color: AppColors.error,
                icono: Icons.remove_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAuditoriaCard(
                titulo: 'Sobrantes',
                unidades: sobrantesUnidades,
                valor: sobrantesValor,
                color: AppColors.infoBlue,
                icono: Icons.add_circle_outline,
              ),
            ),
          ],
        ),

        // 💰 COBRO AL ADMINISTRADOR (solo si hay faltantes)
        if (faltantesValor > 0) ...[
          const SizedBox(height: 16),
          _buildCobroAdministrador(faltantesUnidades, faltantesValor),
        ],

        // 📋 Nota informativa sobre sobrantes
        if (sobrantesUnidades > 0) ...[
          const SizedBox(height: 12),
          _buildNotaSobrantes(),
        ],
      ],
    );
  }

  /// 🎨 Card de auditoría (faltantes/sobrantes)
  Widget _buildAuditoriaCard({
    required String titulo,
    required int unidades,
    required double valor,
    required Color color,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$unidades unidades',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatMoneda(valor),
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// 💰 Card de COBRO AL ADMINISTRADOR
  ///
  /// Muestra el monto total a cobrar por faltantes.
  /// Solo los faltantes se cobran, los sobrantes NO compensan.
  Widget _buildCobroAdministrador(int unidades, double valor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withValues(alpha: 0.2),
            AppColors.error.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COBRO AL ADMINISTRADOR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Responsabilidad por faltantes',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.error.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unidades faltantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unidades prendas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Valor a cobrar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoneda(valor),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.infoBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Este valor NO se compensa con sobrantes',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Nota informativa sobre sobrantes
  ///
  /// Explica que los sobrantes no se cobran, solo se investigan.
  Widget _buildNotaSobrantes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.infoBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.infoBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre los sobrantes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.infoBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Las prendas sobrantes deben ser investigadas. Pueden ser ingresos no registrados o mercancía de otro local. NO se consideran como compensación de faltantes.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 Formatear valores monetarios en pesos colombianos
  String _formatMoneda(double valor) => formatCurrency(valor);
}

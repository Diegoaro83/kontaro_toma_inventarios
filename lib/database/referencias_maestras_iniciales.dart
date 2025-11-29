import 'package:drift/drift.dart' as drift;
import 'drift_database.dart';
import '../services/drift_service.dart';

/// 📚 INICIALIZACIÓN DE REFERENCIAS MAESTRAS
///
/// Este archivo contiene datos de ejemplo para poblar la tabla de Referencias Maestras.
/// Son productos ficticios de Oxígeno Zero Grados para pruebas del sistema.

class ReferenciasMaestrasIniciales {
  static final DriftService _driftService = DriftService();

  /// 🚀 Inicializar referencias maestras con datos de ejemplo
  static Future<void> inicializarReferencias() async {
    try {
      // Verificar si ya existen referencias
      final count = await _driftService.contarReferenciasMaestras();
      if (count > 0) {
        print('✅ Referencias maestras ya inicializadas ($count registros)');
        return;
      }

      print('📦 Iniciando carga de referencias maestras...');

      final referencias = [
        // ==================== CAMISAS ====================
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234567001'),
          nomRef: drift.Value('CAMISA POLO BÁSICA AZUL MARINO'),
          categoria: drift.Value('Camisas'),
          valorSugerido: drift.Value(45000.0),
          tallas: drift.Value('["S","M","L","XL","2XL"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234567002'),
          nomRef: drift.Value('CAMISA POLO RAYAS BLANCO/ROJO'),
          categoria: drift.Value('Camisas'),
          valorSugerido: drift.Value(52000.0),
          tallas: drift.Value('["S","M","L","XL"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234567003'),
          nomRef: drift.Value('CAMISA MANGA LARGA OXFORD BLANCA'),
          categoria: drift.Value('Camisas'),
          valorSugerido: drift.Value(68000.0),
          tallas: drift.Value('["S","M","L","XL","2XL","3XL"]'),
          activo: drift.Value(true),
        ),

        // ==================== PANTALONES ====================
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234568001'),
          nomRef: drift.Value('PANTALÓN JEAN SLIM FIT NEGRO'),
          categoria: drift.Value('Pantalones'),
          valorSugerido: drift.Value(95000.0),
          tallas: drift.Value('["28","30","32","34","36","38"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234568002'),
          nomRef: drift.Value('PANTALÓN JEAN REGULAR AZUL CLARO'),
          categoria: drift.Value('Pantalones'),
          valorSugerido: drift.Value(89000.0),
          tallas: drift.Value('["28","30","32","34","36","38","40"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234568003'),
          nomRef: drift.Value('PANTALÓN CHINO CAQUI'),
          categoria: drift.Value('Pantalones'),
          valorSugerido: drift.Value(72000.0),
          tallas: drift.Value('["30","32","34","36","38"]'),
          activo: drift.Value(true),
        ),

        // ==================== ZAPATOS ====================
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234569001'),
          nomRef: drift.Value('ZAPATO DEPORTIVO CASUAL NEGRO'),
          categoria: drift.Value('Calzado'),
          valorSugerido: drift.Value(125000.0),
          tallas: drift.Value('["38","39","40","41","42","43","44"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234569002'),
          nomRef: drift.Value('ZAPATO FORMAL CUERO CAFÉ'),
          categoria: drift.Value('Calzado'),
          valorSugerido: drift.Value(145000.0),
          tallas: drift.Value('["38","39","40","41","42","43"]'),
          activo: drift.Value(true),
        ),

        // ==================== CHAQUETAS ====================
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234570001'),
          nomRef: drift.Value('CHAQUETA JEAN AZUL OSCURO'),
          categoria: drift.Value('Chaquetas'),
          valorSugerido: drift.Value(115000.0),
          tallas: drift.Value('["S","M","L","XL","2XL"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234570002'),
          nomRef: drift.Value('CHAQUETA BOMBER NEGRA'),
          categoria: drift.Value('Chaquetas'),
          valorSugerido: drift.Value(135000.0),
          tallas: drift.Value('["S","M","L","XL"]'),
          activo: drift.Value(true),
        ),

        // ==================== ACCESORIOS ====================
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234571001'),
          nomRef: drift.Value('CINTURÓN CUERO NEGRO'),
          categoria: drift.Value('Accesorios'),
          valorSugerido: drift.Value(35000.0),
          tallas: drift.Value('["32","34","36","38","40"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234571002'),
          nomRef: drift.Value('GORRA AJUSTABLE AZUL'),
          categoria: drift.Value('Accesorios'),
          valorSugerido: drift.Value(28000.0),
          tallas: drift.Value('["Única"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234571003'),
          nomRef: drift.Value('MEDIAS DEPORTIVAS BLANCAS (PACK X3)'),
          categoria: drift.Value('Accesorios'),
          valorSugerido: drift.Value(18000.0),
          tallas: drift.Value('["S","M","L"]'),
          activo: drift.Value(true),
        ),

        // ==================== PRODUCTOS ADICIONALES ====================
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234572001'),
          nomRef: drift.Value('CAMISETA BÁSICA CUELLO REDONDO GRIS'),
          categoria: drift.Value('Camisetas'),
          valorSugerido: drift.Value(32000.0),
          tallas: drift.Value('["S","M","L","XL","2XL"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234572002'),
          nomRef: drift.Value('BERMUDA JEAN AZUL MEDIO'),
          categoria: drift.Value('Bermudas'),
          valorSugerido: drift.Value(65000.0),
          tallas: drift.Value('["30","32","34","36","38"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234572003'),
          nomRef: drift.Value('BUZO DEPORTIVO GRIS/NEGRO'),
          categoria: drift.Value('Buzos'),
          valorSugerido: drift.Value(98000.0),
          tallas: drift.Value('["S","M","L","XL","2XL"]'),
          activo: drift.Value(true),
        ),
      ];

      // Insertar en lote
      await _driftService.insertarReferenciasMaestrasLote(referencias);

      print(
        '✅ ${referencias.length} referencias maestras creadas exitosamente',
      );
    } catch (e, stackTrace) {
      print('❌ Error al inicializar referencias maestras: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// 🔍 Verificar estado de referencias maestras
  static Future<void> verificarEstado() async {
    try {
      final count = await _driftService.contarReferenciasMaestras();
      print('📊 Total de referencias maestras activas: $count');

      if (count > 0) {
        final referencias = await _driftService.obtenerReferenciasMaestras();
        print('\n📋 Primeras 5 referencias:');
        for (int i = 0; i < (count < 5 ? count : 5); i++) {
          final ref = referencias[i];
          print(
            '  ${i + 1}. ${ref.codRef} - ${ref.nomRef} (\$${ref.valorSugerido})',
          );
        }
      }
    } catch (e) {
      print('❌ Error al verificar referencias: $e');
    }
  }
}

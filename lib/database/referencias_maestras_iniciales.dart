import 'package:drift/drift.dart' as drift;
import 'drift_database.dart';
import '../services/drift_service.dart';
import '../models/referencia_maestra.dart';

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

      final referencias = [
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234567001'),
          nomRef: drift.Value('CAMISA POLO BÁSICA AZUL MARINO'),
          categoria: drift.Value('Camisas'),
          valorSugerido: drift.Value(45000.0),
          tallaDisp: drift.Value('["S","M","L","XL","2XL"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234567002'),
          nomRef: drift.Value('CAMISA POLO RAYAS BLANCO/ROJO'),
          categoria: drift.Value('Camisas'),
          valorSugerido: drift.Value(52000.0),
          tallaDisp: drift.Value('["S","M","L","XL"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('7501234567003'),
          nomRef: drift.Value('CAMISA MANGA LARGA OXFORD BLANCA'),
          categoria: drift.Value('Camisas'),
          valorSugerido: drift.Value(68000.0),
          activo: drift.Value(true),
        ),
        // --- Ejemplos simulando filas reales del Excel ---
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('REF001'),
          nomRef: drift.Value('Camiseta básica algodón'),
          categoria: drift.Value('Camisetas'),
          valorSugerido: drift.Value(25000.0),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('REF002'),
          nomRef: drift.Value('Jean clásico azul'),
          categoria: drift.Value('Jeans'),
          valorSugerido: drift.Value(69000.0),
          tallaDisp: drift.Value('["28","30","32","34","36"]'),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('REF003'),
          nomRef: drift.Value('Sudadera deportiva unisex'),
          categoria: drift.Value('Sudaderas'),
          valorSugerido: drift.Value(55000.0),
          tallaDisp: drift.Value('["S","M","L"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('REF004'),
          nomRef: drift.Value('Chaqueta impermeable'),
          categoria: drift.Value('Chaquetas'),
          valorSugerido: drift.Value(95000.0),
          tallaDisp: drift.Value('["M","L","XL"]'),
          activo: drift.Value(true),
        ),
        ReferenciasMaestrasCompanion(
          codRef: drift.Value('REF005'),
          nomRef: drift.Value('Zapatos deportivos'),
          categoria: drift.Value('Calzado'),
          valorSugerido: drift.Value(120000.0),
          tallaDisp: drift.Value('["38","39","40","41","42"]'),
          activo: drift.Value(true),
        ),
      ];

      // Insertar referencias en la base de datos
      for (final referencia in referencias) {
        // Convertir Companion a modelo ReferenciaMaestra
        final ref = ReferenciaMaestra(
          codRef: referencia.codRef.value,
          nomRef: referencia.nomRef.value,
          codTip: '',
          codPrv: '',
          valRef: 0,
          codEmp: '',
          nomRef1: '',
          nomRef2: '',
          refPrv: '',
          valRef1: 0,
          codMar: '',
          vrunc: 0,
          cos001: '',
          codBarra: '',
          salRef: 0,
          tallaDisp: referencia.tallaDisp.present
              ? referencia.tallaDisp.value
              : '',
          conRec: '',
          valLista1: 0,
          valLista2: 0,
          valLista3: 0,
          activo: referencia.activo.present ? referencia.activo.value : true,
        );
        await _driftService.insertarReferenciaMaestra(ref);
      }

      print(
        '✅ ${referencias.length} referencias maestras creadas exitosamente',
      );
    } catch (e) {
      print('❌ Error al inicializar referencias maestras: $e');
    }
  }
}
